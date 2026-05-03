# Onboarding — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

After Google Sign-In, a user without a `users/{uid}` doc completes onboarding. Two flows: **owner onboarding** (sets up the cycle) and **partner onboarding** (confirms pairing).

---

## Owner onboarding

5 steps, ~30 seconds end-to-end.

| Step | Screen | Outputs |
|---|---|---|
| 1 | Welcome — brand intro, "Let's set up your cycle" | — |
| 2 | "When did your last period start?" — date picker, defaults to current month, max = today | `lastPeriodStart: Date` |
| 3 | "How long is your usual cycle?" — slider 21–45, default 28 | `defaultCycleLength: int` |
| 4 | "Want a heads-up before your period?" — toggle | `notificationsEnabled: bool` |
| 5 | Submitting (single transaction): create user doc + couple doc + first cycle. On success, navigate to `/today`. | — |

`defaultLutealLength` is set to 14 silently. User can adjust later in Settings (rarely needed for MVP audience).

### Business rules

| # | Rule |
|---|---|
| BR-1 | Onboarding cannot be skipped. Without the user doc, all routes redirect back to onboarding. |
| BR-2 | The first cycle is created at the end of onboarding with `startDate = lastPeriodStart`. |
| BR-3 | If the user picks a date > 60 days ago, show a soft prompt: "Has it really been that long? You can pick the most recent date you remember — we'll show low-confidence predictions until you log a real cycle." Allow proceeding either way. |
| BR-4 | Future dates are rejected at the picker level. |
| BR-5 | Sign-out mid-onboarding leaves no Firestore residue — nothing is written until step 5 submits. |
| BR-6 | The submit step is a Firestore transaction across `users/{uid}`, `couples/{id}`, `couples/{id}/cycles/{cycleId}`. All-or-nothing. |
| BR-7 | If notifications are enabled, request OS permission immediately. Denial is OK — feature reverts to off. |

### State machine — `OwnerOnboardingCubit`

```
[Welcome] ──next──> [LastPeriodDate]
[LastPeriodDate] ──pick(date)──> [LastPeriodDate(date)]
[LastPeriodDate(date)] ──next──> [CycleLength(date)]
[CycleLength(date)] ──pick(len)──> [CycleLength(date, len)]
[CycleLength(date, len)] ──next──> [Notifications(date, len)]
[Notifications(date, len)] ──confirm──> [Submitting]
[Submitting] ──ok──> [Done]
[Submitting] ──err──> [Error] ──retry──> [Submitting]

# Back navigation supported between all input steps
```

---

## Partner onboarding

After redeeming an invite code, the partner sees:

| Step | Screen | Outputs |
|---|---|---|
| 1 | "You're paired with [Owner name]" — confirmation, avatar | — |
| 2 | "Get notifications about her cycle?" — toggle, default OFF | `notificationsEnabled: bool` |
| 3 | Submitting (single write): finalize user doc with `role=partner`. Navigate to `/today` (partner view). | — |

Notifications default OFF for the partner per your direction. They can opt in later from Settings.

### Business rules

| # | Rule |
|---|---|
| BR-1 | Partner onboarding is reached only after `redeemInviteCode` succeeds. The user doc already has `coupleId` and `role` set. |
| BR-2 | If pairing succeeds but onboarding crashes, the user doc retains `coupleId` and `role`; on next sign-in they skip directly to `/today`. (No re-prompt.) |

---

## Repository contract

```dart
abstract class OnboardingRepository {
  Future<Result<void>> completeOwnerOnboarding({
    required String userId,
    required String name,
    required String email,
    required String? photoUrl,
    required Date lastPeriodStart,
    required int defaultCycleLength,
    required bool notificationsEnabled,
    required Language language,
  });

  Future<Result<void>> completePartnerOnboarding({
    required String userId,
    required bool notificationsEnabled,
  });
}
```

Both methods are idempotent — re-running on the same uid is a no-op if already complete.

---

## Edge cases

1. **Last period > 60 days ago** — soft prompt, allow proceeding (covers PCOS, post-pill, first-period users).
2. **Network failure on submit** — Submitting → Error, retry button. Transaction is idempotent.
3. **App backgrounded mid-flow** — local cubit state is lost; user restarts from step 1 on resume. Acceptable since flow is short.
4. **OS notification permission denied** — proceed with `notificationsEnabled = false` and a small "you can enable in Settings later" hint.
5. **Re-sign-in after partial onboarding** — no user doc exists, so they restart cleanly.

---

## Test plan

- Cubit transitions for both flows
- Repository: idempotency, transaction failure rollback
- Edge cases 1–5 each get a named test
- Widget tests for date picker constraints (no future dates, > 60 days warning)
