# Settings — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

Settings consolidates user preferences and account controls. One screen, sectioned. Different sections for owner vs. partner.

---

## Sections (owner)

1. **Account**
   - Profile (name, email, photo — read-only, sourced from Google)
   - Language (EN / PT-BR — radio)
   - Sign out
   - Delete account (danger)

2. **Couple**
   - Partner status: "Paired with [name]" or "Not paired yet"
   - Generate / refresh invite code (if not paired)
   - Show active invite code with countdown to expiry (if applicable)
   - "End couple" (danger — removes partner, dissolves couple)

3. **Cycle**
   - Default cycle length (slider, 21–45)
   - Default luteal length (slider, 10–16) — labeled "Time between ovulation and period"
   - View onboarding info (read-only record of what was entered initially)

4. **Notifications**
   - Master toggle
   - Individual: "Period likely starting" / "Period ended"

5. **Security**
   - Biometric lock toggle (Face ID / fingerprint)

6. **Data**
   - Export my data (JSON file)
   - Delete all my data (danger)

7. **About**
   - App version
   - Privacy stance (1-paragraph statement)
   - Open-source acknowledgments (if relevant)

---

## Sections (partner)

1. **Account** (same as owner)
2. **Couple**
   - Paired with [Owner name]
   - **Leave couple** (danger — sets `partnerId = null`)
3. **Notifications**
   - Master toggle (default OFF)
   - "Period likely starting" / "Period ended" — opt-in
4. **Security** (same as owner)
5. **Data**
   - Export my data (only partner notes — owner's data is hers, not exportable from partner side)
6. **About** (same as owner)

Partner does NOT see Cycle settings (those affect predictions; only owner controls them).

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | All "danger" actions require an explicit confirmation dialog with the action label repeated. |
| BR-2 | "Sign out" clears all local Hive boxes and routes to `/sign-in`. Doesn't affect Firestore data. |
| BR-3 | "Delete account" cascades: removes user doc, removes from couple (or dissolves it if owner), revokes Firebase auth credential. Two-step confirmation. |
| BR-4 | "End couple" (owner): sets `partnerId = null`, regenerates a fresh invite-code-eligible state. Partner sees "Couple ended" notice on next launch, returns to pairing flow. |
| BR-5 | "Leave couple" (partner): sets `partnerId = null` on couple, clears `coupleId` and `role` on user. Routes to pairing choice. |
| BR-6 | Language changes apply immediately — slang re-renders. No app restart required. |
| BR-7 | Cycle length / luteal length changes trigger a prediction recompute on the current cycle. |
| BR-8 | Biometric toggle is hidden if device doesn't support biometric auth. |
| BR-9 | All settings writes are optimistic — Hive write applies immediately; Firestore set in background. |

---

## Repository contract

```dart
abstract class SettingsRepository {
  Stream<UserSettings> watchSettings(String userId);
  Future<Result<void>> updateLanguage(String userId, Language language);
  Future<Result<void>> updateNotificationPreferences(String userId, NotificationPrefs prefs);
  Future<Result<void>> updateBiometricEnabled(String userId, bool enabled);
  Future<Result<void>> updateCycleDefaults({
    required String coupleId,
    int? defaultCycleLength,
    int? defaultLutealLength,
  });
}

class UserSettings {
  final Language language;
  final NotificationPrefs notifications;
  final bool biometricEnabled;
  final int defaultCycleLength;        // mirrored from couple, owner only
  final int defaultLutealLength;       // mirrored from couple, owner only
}

class NotificationPrefs {
  final bool master;
  final bool periodLikelyStarting;
  final bool periodEnded;
}
```

---

## State machine — `SettingsCubit`

Standard pattern:

```
[Initial] ──load──> [Loading] ──ok──> [Loaded(settings)]
                              └──err──> [Error]

[Loaded] ──update(field, value)──> [Updating] ──ok──> [Loaded(updatedSettings)]
                                                └──err──> [Error] ──reset──> [Loaded]
```

Each row in the UI dispatches its own update; cubit emits Updating only briefly (optimistic UI shows the new value immediately).

---

## Edge cases

1. **Update during offline** — Hive write applies immediately; Firestore SDK queues the remote write for sync. UI shows the new value; reverts only on hard sync failure (rare).
2. **Two devices change the same setting simultaneously** — last-write-wins via Firestore server timestamp.
3. **Biometric disabled but Settings was on** — toggle visually OFF, hint "Re-enable Face ID in system settings."
4. **Partner edits cycle defaults somehow** — repository rejects (defense in depth, UI shouldn't allow this).
5. **Owner ends couple while partner has unsaved partner-note** — partner's draft note is local; on next launch, partner sees "Couple ended" and the draft is discarded.
6. **Account deletion mid-Firestore write** — best effort cleanup; orphan docs are tolerable since this is personal-use scope.

---

## Test plan

- Each `update*` method: success, failure, optimistic UI behavior
- Cycle defaults change triggers prediction recompute (integration test)
- Language change re-renders slang strings (widget test)
- Owner sees Cycle section, partner does not
- Two-step confirmation on all danger actions (widget test)
