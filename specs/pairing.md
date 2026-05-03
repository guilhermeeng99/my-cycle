# Pairing — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

Pairing connects two authenticated users (one owner + one partner) into a single Couple. Owner generates an invite code; partner redeems it.

---

## Overview

After Google Sign-In, a user without a `coupleId` chooses one of two paths:

- **"I want to track my cycle"** → becomes owner of a new couple. Generates an invite code to share with partner.
- **"I'm joining someone"** → becomes partner. Enters an invite code to join.

A couple is locked at 2 members once `partnerId` is set. The partner can leave (re-pairs later); the owner cannot remove the partner.

---

## Invite code format

- 6 uppercase alphanumeric chars from the set `[A-Z0-9]` excluding visually ambiguous chars: `O`, `0`, `I`, `1`, `L`.
- Effective alphabet: `ABCDEFGHJKMNPQRSTUVWXYZ23456789` (31 chars).
- Search space: 31⁶ ≈ 887M. Negligible collision risk with sub-100 active codes.
- Codes expire **24 hours** after generation.
- Only one active invite per couple at a time. Generating a new one invalidates the previous.

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | Only the owner generates invite codes. Partners enter them. |
| BR-2 | Codes expire 24h after generation. Expired codes are rejected with a clear "ask for a new one" message. |
| BR-3 | Only one active code per couple. Generating a new one invalidates the previous. |
| BR-4 | A user without a `coupleId` must choose owner OR partner before doing anything else. |
| BR-5 | A couple is locked at 2 members. Subsequent redemption attempts on any code from a full couple fail with `coupleFull`. |
| BR-6 | Partner can leave the couple via Settings → "Leave couple." Sets `partnerId = null`. Owner sees a notice on next launch. |
| BR-7 | Owner cannot remove the partner directly — only the partner removes themselves. (Avoids one-sided control over shared data.) |
| BR-8 | After leaving, the former partner can pair again with any valid code. Their `coupleId` and `role` are cleared on leave. |
| BR-9 | Redeem must be **transactional** across `couples/{id}` and `users/{uid}` — both updates succeed or both fail. |

---

## Repository contract

```dart
abstract class CoupleRepository {
  Stream<Couple?> watchCouple(String coupleId);

  Future<Result<Couple>> createCoupleAsOwner({
    required String ownerId,
    required int defaultCycleLength,
    required int defaultLutealLength,
  });

  Future<Result<InviteCode>> generateInviteCode(String coupleId);

  Future<Result<Couple>> redeemInviteCode({
    required String partnerId,
    required String code,
  });

  Future<Result<void>> leaveCouple({
    required String coupleId,
    required String userId,
  });
}

class InviteCode {
  final String code;
  final DateTime expiresAt;
}
```

---

## State machines

### `PairingChoiceCubit` (post-sign-in entry point)

```
[Idle] ──chooseOwner──> [CreatingCouple] ──ok──> [PairedAsOwner(couple)]
                                          └──err──> [Error(failure)]

[Idle] ──choosePartner──> [EnterCode]

[EnterCode] ──submit(code)──> [Redeeming] ──ok──> [PairedAsPartner(couple)]
                                          ├──invalidCode──> [InvalidCode]
                                          ├──expired──> [Expired]
                                          ├──coupleFull──> [Full]
                                          └──networkError──> [Retryable]

[InvalidCode | Expired | Full | Retryable] ──reset──> [EnterCode]
```

### `InviteCodeCubit` (owner generating / refreshing codes)

```
[Idle] ──generate──> [Generating] ──ok──> [Generated(code, expiresAt)]
                                   └──err──> [Error]

[Generated] ──refresh──> [Generating]   # invalidates the previous code
```

---

## Redeem transaction (Firestore)

The redemption must atomically update two documents. Pseudocode:

```dart
firestore.runTransaction((tx) async {
  // 1. Find couple by inviteCode (requires composite index)
  final couple = tx.get(couplesQuery.where('inviteCode', '==', code).limit(1));
  if (couple == null) throw PairingFailure.invalidCode;
  if (couple.inviteExpiresAt < now) throw PairingFailure.expiredCode;
  if (couple.partnerId != null) throw PairingFailure.coupleFull;

  // 2. Atomically:
  tx.update(couples/{coupleId}, {
    partnerId: partnerId,
    inviteCode: null,
    inviteExpiresAt: null,
    updatedAt: now,
  });
  tx.update(users/{partnerId}, {
    coupleId: coupleId,
    role: 'partner',
    updatedAt: now,
  });
});
```

Required Firestore index: `couples` collection on `inviteCode` (ascending), single-field. Configure in `firestore.indexes.json`.

---

## Firestore security rules (essential)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helpers
    function isSignedIn() {
      return request.auth != null;
    }

    function isCoupleMember(coupleId) {
      let c = get(/databases/$(database)/documents/couples/$(coupleId)).data;
      return request.auth.uid == c.ownerId || request.auth.uid == c.partnerId;
    }

    function isCoupleOwner(coupleId) {
      let c = get(/databases/$(database)/documents/couples/$(coupleId)).data;
      return request.auth.uid == c.ownerId;
    }

    // Users — each user reads/writes only their own doc
    match /users/{userId} {
      allow read: if isSignedIn() && request.auth.uid == userId;
      allow write: if isSignedIn() && request.auth.uid == userId;
    }

    // Couples
    match /couples/{coupleId} {
      // Read: members only
      allow read: if isSignedIn()
                  && (request.auth.uid == resource.data.ownerId
                      || request.auth.uid == resource.data.partnerId);

      // Create: only as owner, partnerId must be null
      allow create: if isSignedIn()
                    && request.resource.data.ownerId == request.auth.uid
                    && request.resource.data.partnerId == null;

      // Update by owner: cannot change ownerId
      allow update: if isSignedIn()
                    && request.auth.uid == resource.data.ownerId
                    && request.resource.data.ownerId == resource.data.ownerId;

      // Update by partner: only to leave (set partnerId to null)
      allow update: if isSignedIn()
                    && request.auth.uid == resource.data.partnerId
                    && request.resource.data.partnerId == null
                    && request.resource.data.ownerId == resource.data.ownerId
                    && request.resource.data.defaultCycleLength == resource.data.defaultCycleLength
                    && request.resource.data.defaultLutealLength == resource.data.defaultLutealLength;

      // Update for redemption (special case): partnerId goes from null to request.auth.uid
      // This is handled by the same transaction that updates users/{uid}; rules permit this when:
      //   - existing partnerId is null
      //   - new partnerId equals request.auth.uid
      //   - inviteCode and inviteExpiresAt are cleared
      // Combined with the partner-leave rule above by checking either-or in update.
    }

    // Cycles — read by both members, write by owner only
    match /couples/{coupleId}/cycles/{cycleId} {
      allow read: if isCoupleMember(coupleId);
      allow write: if isCoupleOwner(coupleId);
    }

    // DayLogs — read by both, write per role
    match /couples/{coupleId}/days/{date} {
      allow read: if isCoupleMember(coupleId);

      allow write: if isCoupleOwner(coupleId)
                   || (request.auth.uid == get(/databases/$(database)/documents/couples/$(coupleId)).data.partnerId
                       && partnerWriteOnlyChangesPartnerNote());
    }

    function partnerWriteOnlyChangesPartnerNote() {
      // Compare resource.data and request.resource.data — only partnerNote and updatedAt may differ.
      let allowedKeys = ['partnerNote', 'updatedAt'];
      let changedKeys = request.resource.data.diff(resource.data).affectedKeys();
      return changedKeys.hasOnly(allowedKeys);
    }
  }
}
```

> The redeem rule needs careful refinement once we implement — write rule tests in the Firestore Rules Emulator. Acceptance criteria: a partner can claim an empty couple by transaction, a partner can leave, but neither can change cycle data or arbitrary fields.

---

## Edge cases

1. **Code does not exist** → `PairingFailure.invalidCode`. Generic message ("This code isn't valid"), no enumeration of codes.
2. **Code expired** → `PairingFailure.expiredCode`. UI: "Ask your partner for a new code."
3. **Couple is full** → `PairingFailure.coupleFull`. UI: "This invite was already used."
4. **Two partners try to redeem the same code simultaneously** → first wins via Firestore transaction; second sees `coupleFull`.
5. **User redeems while their own `coupleId` is set** → `PairingFailure.alreadyInCouple`. They must leave their current couple first.
6. **Owner generates 2nd code while first unredeemed** → previous invalidated, new code shown. Old code immediately fails `invalidCode`.
7. **Network error during redeem** → retry-able, transaction is idempotent (either no-op or completed).
8. **Owner deletes account** → couple is dissolved server-side via Cloud Function (or app-side cleanup). Partner's app sees `coupleId` no longer resolves and routes to "Couple ended" screen, then back to pairing choice.
9. **Partner deletes account** → owner's `couples/{id}.partnerId` reverts to null (cleanup). Owner sees "Partner left."
10. **Code redeemed offline** → fails immediately, no offline queueing for pairing (we want the user to see the result in real time).

---

## Failures

- `PairingFailure.invalidCode`
- `PairingFailure.expiredCode`
- `PairingFailure.coupleFull`
- `PairingFailure.alreadyInCouple`
- `NetworkFailure`
- `StorageFailure`

---

## Test plan

- Invite code generator: 6-char output, excluded charset, expiry math, uniqueness in a set of 1000
- Repository: redeem happy path, all 5 failure modes, leave couple, owner-only operations
- Firestore Rules Emulator tests:
  - Owner can read & write couple
  - Partner can read couple, can only set `partnerId = null` (leave), nothing else
  - Outsider gets read denied
  - Partner can write only to `partnerNote` on a DayLog
  - Owner can write all DayLog fields
- State machine tests for `PairingChoiceCubit` and `InviteCodeCubit`
- Edge cases 1–10 each get a named test
