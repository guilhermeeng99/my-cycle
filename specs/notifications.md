# Notifications — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

Local notifications only — no Firebase Cloud Messaging in MVP. Minimal by design: two types, owner-only by default. Driven by `flutter_local_notifications`.

---

## Notification types

| Type | When | Recipient (default) | Body (PT-BR) | Body (EN) |
|---|---|---|---|---|
| `period_likely_starting` | `predictedNextStart - 1d` at 09:00 local | Owner | "Sua menstruação deve começar amanhã. Tudo bem por aí?" | "Your period is likely starting tomorrow. How are you feeling?" |
| `period_ended` | When `periodEndDate` is set, immediate | Owner | "Período registrado como encerrado em {date}." | "Period logged as ended on {date}." |

Two notifications. That's the entire MVP set. We resist adding more.

Partner can opt in to both via Settings (default OFF). Wording stays neutral and respectful when delivered to the partner — same body, no special copy.

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | Notifications are local — scheduled on-device via `flutter_local_notifications`. No backend, no FCM. |
| BR-2 | Owner default: notifications enabled at onboarding step 4 (toggle, defaults ON). |
| BR-3 | Partner default: notifications OFF. Opt-in via Settings only. |
| BR-4 | OS permission requested at the moment notifications are enabled — never preemptively at onboarding before the user has chosen. |
| BR-5 | If OS permission is denied, the in-app toggle reverts to OFF and shows a hint: "Enable in system settings to receive reminders." |
| BR-6 | `period_likely_starting` is rescheduled whenever `currentCycle.predictedNextStart` changes. |
| BR-7 | If a scheduled notification's date has passed when the app reschedules, it's cancelled silently — no late delivery. |
| BR-8 | Quiet hours are respected: notifications scheduled between 22:00 and 08:00 local time are deferred to 09:00 the next day. |
| BR-9 | All notifications are channel-grouped under "Cycle reminders" (Android channel `cycle_reminders`). |

---

## Repository contract

```dart
abstract class NotificationsRepository {
  Future<bool> requestPermission();
  Future<bool> hasPermission();

  Future<Result<void>> schedulePeriodStarting({
    required DateTime when,
    required Language language,
  });

  Future<Result<void>> notifyPeriodEnded({
    required Date endedDate,
    required Language language,
  });

  Future<Result<void>> cancelAll();
  Future<Result<void>> cancelByType(NotificationType type);
}

enum NotificationType { periodLikelyStarting, periodEnded }
```

The repository wraps `flutter_local_notifications` and is injected. A `NotificationsCoordinator` (in `core/notifications/`) listens to cycle stream changes and reschedules accordingly.

---

## Coordinator behavior

The `NotificationsCoordinator` is a long-lived service registered as singleton in DI:

```
on currentCycle change:
  if predictedNextStart changed:
    cancel previous period_likely_starting
    if user has notifications enabled and OS permission granted:
      schedule new period_likely_starting at (predictedNextStart - 1d) @ 09:00 local
      apply quiet-hours deferral if applicable

on cycle.periodEndDate set:
  if user has notifications enabled and OS permission granted:
    notifyPeriodEnded immediate

on user signed out:
  cancelAll
```

Idempotent: calling reschedule twice in a row produces the same final state.

---

## Permissions

- Android 13+: `POST_NOTIFICATIONS` runtime permission required. Requested when user enables notifications.
- iOS (not deploying, but spec for completeness): permission via `flutter_local_notifications` standard prompt.
- Permission denial is graceful — toggle reverts, hint shown, no exception.

---

## Edge cases

1. **App killed before notification fires** — Android scheduled notifications fire regardless. iOS same.
2. **Predictions change overnight** — rescheduling on next app open or via cycle-data Firestore listener catches up.
3. **Period actually starts before predicted date** — `predicted_next_start - 1d` notification was already cancelled when the new cycle started (cancel on cycle creation).
4. **Period starts after predicted date by N days** — late banner shows on Today; no extra notification (avoids nagging).
5. **OS permission revoked mid-use** — next reschedule attempt fails silently, in-app toggle stays ON; we don't auto-toggle OFF (user decides).
6. **User changes language** — next scheduled notification uses the new language. Already-scheduled notifications fire in the prior language until the next reschedule.
7. **Partner enabled notifications** — both members get the same reminder; copy is identical and gender-neutral.

---

## Test plan

- Coordinator: schedule, cancel, reschedule on cycle change
- Quiet hours: 22:00 schedule defers to 09:00 next day
- Permission denial: toggle reverts, hint shown
- i18n: notification body uses the user's `language` field
- Edge cases 1–7 each get a named test
