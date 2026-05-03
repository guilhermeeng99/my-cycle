# Data Export & Deletion — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

Even though MyCycle is a personal app, the user's data is sensitive. Export-my-data and delete-my-data are non-negotiable affordances. Both work offline (data is in Hive cache).

---

## Export-my-data

### Format

A single JSON file. Human-readable, structured for portability.

```json
{
  "schemaVersion": 1,
  "exportedAt": "2026-05-03T18:42:00Z",
  "user": {
    "id": "...",
    "name": "...",
    "email": "...",
    "role": "owner",
    "language": "ptBr"
  },
  "couple": {
    "id": "...",
    "ownerId": "...",
    "partnerId": "...",
    "defaultCycleLength": 28,
    "defaultLutealLength": 14
  },
  "cycles": [
    {
      "id": "...",
      "startDate": "2026-04-12",
      "periodEndDate": "2026-04-17",
      "totalLengthDays": 29,
      "predictedNextStart": "2026-05-11",
      "predictedNextStartRangeEnd": "2026-05-13",
      "predictedOvulation": "2026-04-27",
      "predictionConfidence": "medium"
    }
  ],
  "dayLogs": [
    {
      "date": "2026-04-12",
      "flow": "medium",
      "symptoms": ["cramps", "fatigue"],
      "mood": "irritable",
      "ownerNote": "Cólicas fortes hoje",
      "partnerNote": null
    }
  ]
}
```

### Behavior

- Generated **on-device**, no backend round-trip.
- Reads from Hive cache (kept in sync by the Firestore listeners). If cache is stale, attempt a fresh Firestore read first.
- Filename: `mycycle-export-{YYYY-MM-DD}.json`
- Saved via `share_plus` so the user picks the destination (Drive, email, etc.) — no implicit cloud upload.

### Owner vs. partner export

- **Owner** export includes everything: user, couple, cycles, all day logs (including `partnerNote` fields).
- **Partner** export includes their user record + their `partnerNote` entries only. Cycles and the owner's notes are not exported by the partner — that data belongs to the owner.

---

## Delete-my-data

### Two flavors

1. **Delete account** — wipes the user from the system. From Settings → Account → Delete account.
2. **Delete all my data** — keeps the account, wipes cycles + DayLogs. From Settings → Data → Delete all my data.

Both require **two-step confirmation**: a dialog explaining what will be deleted, then a typed confirmation ("type DELETE to confirm").

### Delete account flow

```
1. User confirms.
2. If owner with partner: dissolve the couple (set partnerId to null on couple, clear coupleId on partner user).
3. Delete user doc.
4. If owner: delete couple doc, all cycles subcollection, all days subcollection.
5. Sign out.
6. Revoke Firebase auth credential (firebaseAuth.currentUser.delete()).
7. Clear all local Hive boxes.
8. Route to /sign-in with a "Account deleted" toast.
```

### Delete all my data flow (owner only — partner has nothing equivalent)

```
1. User confirms.
2. Delete all cycles subcollection.
3. Delete all days subcollection.
4. Reset couple's defaultCycleLength, defaultLutealLength to baseline (28, 14).
5. Local Hive boxes cleared.
6. Route to onboarding (re-do step 2: when did your last period start?).
```

This effectively rewinds to post-onboarding state.

### Partner cannot delete owner's data

The "delete all data" action is hidden for partners. They can only delete their own account (which removes them from the couple, leaving the owner's data intact).

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | Export works offline from the Hive cache. If cache is stale, sync attempt is best-effort with a "you may not have the latest data" hint. |
| BR-2 | Delete account is irreversible — confirmation copy must say so explicitly. |
| BR-3 | Delete all data preserves the user's account and couple but wipes cycle/day data. |
| BR-4 | Partners cannot wipe owner data via any path (UI hidden, repository rejects). |
| BR-5 | Owner deletes account → couple is dissolved, partner notified on next launch. |
| BR-6 | Partner deletes account → couple's `partnerId` clears; owner notified on next launch. |
| BR-7 | Failed delete (network, permissions) leaves the data intact and surfaces a retry option. Never half-delete. |

---

## Repository contract

```dart
abstract class DataExportRepository {
  Future<Result<File>> exportToJsonFile({
    required String userId,
    required String coupleId,
  });
}

abstract class DataDeletionRepository {
  Future<Result<void>> deleteAccount(String userId);
  Future<Result<void>> deleteAllCycleData(String coupleId);  // owner only
}
```

Both write to Firestore via batched writes / transactions and then clear the corresponding Hive boxes.

---

## Edge cases

1. **Export with empty data** — produces a valid JSON with empty arrays. Don't error.
2. **Delete account fails halfway** — surface error, user retries. Acceptable to have orphans on retry-success (best-effort cleanup).
3. **Network unavailable for delete** — surface error, ask user to retry online. Hive not cleared until Firestore confirms.
4. **User deletes account while partner is mid-edit** — partner's local edit fails on next sync; partner sees "Couple ended."
5. **Export file generation fails (storage full, permission denied)** — surface error, no partial file written.
6. **Schema version drift** — `schemaVersion: 1` written today; future imports (Phase 2 if we add it) handle migration.

---

## Test plan

- Export: structure matches schema, owner export includes all data, partner export is scoped
- Delete account: cascades correctly (owner dissolves couple, partner only clears self)
- Delete all data: cycles + days emptied, couple + user preserved, predictions reset
- Partner cannot trigger owner-data deletion (UI + repository)
- Edge cases 1–6 each get a named test
