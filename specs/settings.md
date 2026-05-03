# Settings — Specification

> Status: draft v3 · Owner: @guiga · Last updated: 2026-05-03

Settings consolidates user preferences and account controls. One screen, sectioned. Different sections for owner vs. partner.

---

## Sections (owner)

1. **Account**
   - Profile (name, email, photo — read-only, sourced from Google)
   - Language (EN / PT-BR — radio)
   - Sign out
   - Delete account (danger)

2. **Appearance**
   - Theme mode (Match system / Light / Dark — radio)
   - Persisted via `SharedPreferences` (key `theme_mode`); applies immediately and survives cold start
   - Owned by [`ThemeCubit`](theme.md), not `SettingsCubit` — it's app-wide UI state, not user-account state

3. **Couple**
   - Partner status: "Paired with [name]" or "Not paired yet"
   - Generate / refresh invite code (if not paired)
   - Show active invite code with countdown to expiry (if applicable)
   - "End couple" (danger — removes partner, dissolves couple)

4. **Cycle** *(owner only — partner doesn't see this section)*
   - Default cycle length: slider 21–45 days, persisted on slider release
     (`onChangeEnd`) via `SettingsCubit.updateCycleDefaults`. Writes to
     the couple doc; security rules enforce owner-only.
   - Default luteal length: slider 10–16 days. Labeled "Time between
     ovulation and period."
   - Both writes trigger an automatic prediction recompute the next time
     the prediction engine runs (the engine reads couple defaults from
     each `PredictionInput`, so no manual refresh is needed).

5. **Notifications**
   - Master toggle
   - Individual: "Period likely starting" / "Period ended"

6. **Security**
   - Biometric lock toggle (Face ID / fingerprint). The toggle is hidden
     when `BiometricRepository.isAvailable()` returns false. See
     [biometric.md](biometric.md) for the full state machine.

7. **Data**
   - Export my data (JSON file)
   - Delete all my data (danger)

8. **About**
   - App version + build number (from `package_info_plus`)
   - Privacy stance: one-paragraph statement reaffirming that cycle data
     stays in the user's Firebase project and that no analytics covers
     cycle content.

---

## Sections (partner)

1. **Account** (same as owner)
2. **Appearance** (same as owner)
3. **Couple**
   - Paired with [Owner name]
   - **Leave couple** (danger — sets `partnerId = null`)
4. **Notifications**
   - Master toggle (default OFF)
   - "Period likely starting" / "Period ended" — opt-in
5. **Security** (same as owner)
6. **Data**
   - Export my data (only partner notes — owner's data is hers, not exportable from partner side)
7. **About** (same as owner)

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
| BR-10 | Theme mode is local-device state (not synced via Firestore). Stored in `SharedPreferences` so each device keeps its own preference. |

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
