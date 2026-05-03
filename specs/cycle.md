# Cycle — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

The cycle feature is the load-bearing core of MyCycle. The Today screen, Calendar, predictions, and notifications all read from it.

---

## Overview

A **Cycle** represents one menstrual cycle — from day 1 of period to day 1 of the next period. The owner (wife) starts cycles by logging flow; the partner (husband) reads cycle state.

A **DayLog** holds per-date data (flow level, symptoms, mood, notes). DayLogs and Cycles are independent: a DayLog exists per logged date regardless of cycle boundaries. The cycle gives time its structure; the DayLog records what happened on a given day.

---

## Entity contracts

### Cycle

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | `String` | no | UUID v4 |
| `coupleId` | `String` | no | foreign key to `Couple` |
| `startDate` | `Date` | no | day 1 of period (date-only, no time component) |
| `periodEndDate` | `Date` | yes | last day of bleeding; null while ongoing |
| `totalLengthDays` | `int` | yes | computed when next cycle starts; `next.startDate − this.startDate` |
| `predictedNextStart` | `Date` | yes | range start (see predictions.md) |
| `predictedNextStartRangeEnd` | `Date` | yes | range end |
| `predictedOvulation` | `Date` | yes | predicted ovulation date |
| `predictionConfidence` | `enum {low, medium, high}` | yes | denormalized cache from prediction engine |
| `createdAt` | `DateTime` | no | server timestamp |
| `updatedAt` | `DateTime` | no | server timestamp |

**Invariants:**

- `startDate` is unique per `coupleId`. No two cycles share a start date.
- If `periodEndDate` is set: `periodEndDate >= startDate`.
- `totalLengthDays`, when set, must be in `[15, 60]`. Outside that range is data corruption — refuse to save and surface a validation error.
- Only one cycle per couple has `totalLengthDays == null` at a time. That is the **current** cycle.

### DayLog

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `coupleId` | `String` | no | composite PK with `date` |
| `date` | `Date` | no | composite PK |
| `flow` | `enum {spotting, light, medium, heavy}` | yes | null = no period bleeding logged |
| `symptoms` | `Set<SymptomType>` | no | empty set if none |
| `mood` | `enum {happy, calm, irritable, sad, anxious}` | yes | |
| `ownerNote` | `String` | yes | max 500 chars |
| `partnerNote` | `String` | yes | max 500 chars |
| `createdAt` | `DateTime` | no | |
| `updatedAt` | `DateTime` | no | |

**SymptomType (MVP, simple):** `cramps`, `headache`, `bloating`, `fatigue`, `tenderBreasts`, `acne`, `backPain`, `nausea`. Eight items — simple by design.

**Invariants:**
- `(coupleId, date)` is the natural primary key. Only one DayLog per couple per date.
- All fields except `coupleId` and `date` can be empty/null. An empty DayLog (all null/empty) should be deleted, not stored.

### Couple

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | `String` | no | UUID v4 |
| `ownerId` | `String` | no | Firebase auth uid of the owner |
| `partnerId` | `String` | yes | null until paired |
| `inviteCode` | `String` | yes | 6 uppercase chars `[A-Z0-9]`; null after redemption or expiry |
| `inviteExpiresAt` | `DateTime` | yes | |
| `defaultCycleLength` | `int` | no | user-set in onboarding (default 28) |
| `defaultLutealLength` | `int` | no | default 14, user-editable in settings |
| `createdAt` | `DateTime` | no | |
| `updatedAt` | `DateTime` | no | |

**Invariants:**
- A couple is locked at 2 members once `partnerId` is set. No third member ever joins.
- `defaultCycleLength` ∈ `[21, 45]`. `defaultLutealLength` ∈ `[10, 16]`.

### CyclePhase (derived, not stored)

```
enum CyclePhase {
  menstrual,    // dayN within period (start through periodEndDate or predicted period end)
  follicular,   // after period through day before fertile window
  ovulation,    // fertile window (5 days before predicted ovulation through ovulation day)
  luteal,       // after fertile window through next period
  unknown,      // cycle data insufficient to compute
}
```

Computed by a pure function from current cycle + DayLogs + prediction:

```dart
CyclePhase computePhase({
  required Cycle currentCycle,
  required PredictionOutput? prediction,
  required Date today,
  required List<DayLog> recentDayLogs,
});
```

Logic:
- `today` ∈ `[startDate, periodEndDate or estimated period end]` → `menstrual`
- `today` ∈ fertile window → `ovulation`
- `today` between period end and fertile window start → `follicular`
- `today` after fertile window through `predictedNextStart` → `luteal`
- Prediction unavailable → `unknown`

---

## Business rules

Numbered for test traceability — `cycle_test.dart` test names reference `BR-3` etc.

| # | Rule |
|---|---|
| BR-1 | A cycle starts when the owner logs any flow on a date that has no current open cycle. |
| BR-2 | The owner can also start a cycle explicitly via "Period started today." This is the preferred path; auto-start (BR-1) is a convenience. |
| BR-3 | When a new cycle starts, the previous cycle (if any) is closed: `previous.totalLengthDays = newCycle.startDate − previous.startDate`. |
| BR-4 | Period end is detected after **2+ consecutive non-flow days** following a flow streak. UI **prompts** the owner to confirm; we never auto-set `periodEndDate` silently. |
| BR-5 | Owner can manually mark "Period ended on [date]" via an explicit action in the day-detail screen. |
| BR-6 | Owner can edit any cycle's `startDate` or `periodEndDate` from the calendar via long-press → Edit. Edits trigger prediction recompute. |
| BR-7 | Partner cannot edit cycle dates, flow, symptoms, or mood. UI hides those affordances; repository rejects with `ValidationFailure.partnerCannotEditOwnerData`. |
| BR-8 | Both owner and partner can read all cycle and DayLog data within their couple. |
| BR-9 | Both can write to their own `*Note` field on a DayLog (`ownerNote` for owner, `partnerNote` for partner). |
| BR-10 | If a logged flow date precedes the predicted next-start date, the cycle is recorded as "early." If it succeeds the predicted range, "late." This metadata feeds the prediction engine. |
| BR-11 | If the predicted period start passes with no flow logged, after **3+ days late** show a gentle banner: "Late by N days. Log flow when it starts." |
| BR-12 | Cycles are kept indefinitely. Cycles older than 24 months are queryable but down-weighted in predictions (see `predictions.md`). |
| BR-13 | Onboarding values for `defaultCycleLength` and `defaultLutealLength` seed predictions until 3+ cycles exist. After that, predictions use the engine's adaptive algorithm. |
| BR-14 | All dates are stored as **date-only** (no time, no timezone). Storage format: `YYYY-MM-DD` strings. UI renders in device locale. |

---

## Repository contracts

```dart
abstract class CycleRepository {
  Stream<Cycle?> watchCurrentCycle(String coupleId);
  Stream<List<Cycle>> watchRecentCycles(String coupleId, {int limit = 12});
  Future<Result<Cycle>> getCycleById(String id);

  Future<Result<Cycle>> startNewCycle({
    required String coupleId,
    required Date startDate,
  });

  Future<Result<Cycle>> setPeriodEnd({
    required String cycleId,
    required Date endDate,
  });

  Future<Result<Cycle>> updateCycleDates({
    required String cycleId,
    Date? startDate,
    Date? periodEndDate,
  });

  Future<Result<void>> deleteCycle(String cycleId);
}

abstract class DayLogRepository {
  Stream<DayLog?> watchDay(String coupleId, Date date);
  Stream<List<DayLog>> watchRange(String coupleId, Date from, Date to);

  Future<Result<DayLog>> setFlow({
    required String coupleId,
    required Date date,
    required FlowLevel? flow,
  });

  Future<Result<DayLog>> setSymptoms({
    required String coupleId,
    required Date date,
    required Set<SymptomType> symptoms,
  });

  Future<Result<DayLog>> setMood({
    required String coupleId,
    required Date date,
    required MoodType? mood,
  });

  Future<Result<DayLog>> setOwnerNote({
    required String coupleId,
    required Date date,
    required String? note,
  });

  Future<Result<DayLog>> setPartnerNote({
    required String coupleId,
    required Date date,
    required String? note,
  });
}
```

All methods return `Future<Result<T>>` where `Result<T>` is a sealed class: `Success<T>` | `Failure(AppFailure)`.

Failures relevant to this feature:

- `StorageFailure(cause)` — Firestore or Hive write error
- `OfflineFailure` — write queued locally, treated as success in UI but flagged as "pending"
- `ValidationFailure.invalidDateRange`
- `ValidationFailure.cycleLengthOutOfBounds`
- `ValidationFailure.partnerCannotEditOwnerData`
- `ValidationFailure.duplicateCycleStart`

---

## State machines

### `CurrentCycleCubit` — drives Today screen

```
[Initial] ──load()──> [Loading] ──data──> [Loaded(currentCycle, dayN, phase)]
                                  └──no cycle──> [Empty]
                                  └──error──> [Error(failure)]
```

`Loaded` state contents:
- `currentCycle: Cycle`
- `dayN: int` — day of cycle (1-indexed)
- `phase: CyclePhase`
- `recentLogs: List<DayLog>` — last 7 days
- `prediction: PredictionOutput`

The cubit subscribes to `watchCurrentCycle` and re-emits `Loaded` whenever the cycle or any of the last 7 DayLogs change.

### `LogActionCubit` — drives the "Log today" CTA

```
[Idle] ──submit(action)──> [Saving] ──ok──> [Success] ──reset──> [Idle]
                                    └──err──> [Error(failure)] ──reset──> [Idle]
```

One-tap logger. Actions: `LogPeriodStarted`, `LogFlow(level)`, `LogPeriodEnded`.

### `CycleEditorCubit` — drives manual cycle date edits

```
[Loaded(cycle)] ──edit(startDate?, periodEndDate?)──> [Validating]
                                                     ──valid──> [Saving] ──ok──> [Saved] ──> [Loaded(updatedCycle)]
                                                                          └──err──> [Error]
                                                     ──invalid──> [InvalidInput(reason)] ──> [Loaded]
```

---

## Edge cases

1. **Retroactive period log.** Owner logs flow on a past date with no surrounding cycle → create cycle retroactively, recompute predictions. If the date lands inside another cycle's window, just upsert the DayLog without creating a new cycle.
2. **Flow log inside an existing cycle's period window.** Adds to the day log; no new cycle created.
3. **Flow log after predicted next-start with no new cycle yet.** Auto-start a new cycle on that date (BR-1).
4. **Owner deletes the only cycle.** State → `Empty`. Predictions revert to onboarding defaults.
5. **Owner deletes the most recent cycle.** Recompute predictions from remaining cycles. The previous cycle becomes "current" (its `totalLengthDays` is cleared).
6. **Daylight saving / leap year / year boundary.** No special handling — date-only storage sidesteps all of these.
7. **Re-opening a closed cycle.** Owner can reopen the most recent closed cycle within 48h of its closure (small undo window). Older cycles are locked; editing requires explicit `updateCycleDates`.
8. **Two devices write conflicting day logs simultaneously.** Last-write-wins by Firestore server timestamp. UI on the loser device silently re-renders with the winner's value.
9. **Offline write.** Optimistic UI: written to Hive immediately; Firestore SDK queues the remote write while offline. Pending state shown (small dot) until the remote write is acked. If the remote write fails for a real reason (not offline), revert the Hive value and surface a soft retry banner.
10. **Partner attempts to write owner-only field.** UI hides the affordance. If a malformed client sends the request, repository returns `ValidationFailure.partnerCannotEditOwnerData`. Firestore security rules also reject server-side (defense in depth).
11. **Solo owner (no partner yet).** Partner-only UI surfaces are hidden. `partnerNote` reads always return null. Owner-mode is fully usable.
12. **Cycle longer than 60 days reported.** Refuse to save; surface a banner suggesting "looks like a cycle was missed — would you like to log it?" rather than silently accepting bad data.
13. **User signed out or `coupleId == null`.** All cycle features unavailable. Router redirects to auth/pairing flow.

---

## Notification hooks (minimal)

Triggered by cycle state transitions:
- `predictedNextStart - 1d` → "Period likely starting tomorrow" (owner only)
- `periodEndDate` newly set → "Period ended" (owner only — informational, opt-in)

Both are local notifications scheduled via `flutter_local_notifications`. Re-scheduled whenever predictions change.

A separate `notifications.md` spec will detail this when we get there.

---

## Test plan (high level)

- Entity invariants (Cycle, DayLog, Couple) — pure unit tests
- BR-1 through BR-14 — each gets at least one test in `cycle_repository_test.dart`
- State machine transitions — `bloc_test` per cubit
- Edge cases 1–13 — explicit tests, named after the case number
- Property test: any sequence of valid `setFlow` calls maintains "at most one open cycle"
- Date math: explicit tests for year boundaries, Feb 29, and DST-affected dates (using a fake `Clock`)
