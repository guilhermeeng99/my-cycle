# Calendar — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

**The hero feature.** Calendar is what your wife will use most. Month grid, swipe between months, tap any day for detail, long-press to edit (owner only).

---

## Visual layout

```
┌──────────────────────────────┐
│  ‹  May 2026             ›   │  ← month header with chevrons
│         [Today]              │  ← "today" pill (returns to current month)
├──────────────────────────────┤
│  S  M  T  W  T  F  S         │  ← weekday header (locale-aware)
├──────────────────────────────┤
│  •  •  •  ●  ●  ●  ●         │  ← day cells, 6 rows × 7 cols
│  ●  ●  ⊕  ⊕  ⊕  ⊕  ⊕         │
│  ⊕  ⊕  ⊕  ◯  ◯  ◯  ◯         │  ← ⊕ = predicted period (dashed)
│  ◯  ◉  ◯  ◯  ◯  ◯  ◯         │  ← ◉ = predicted ovulation
│  ◯  ◯  ◯  ●  ●  ●  ●         │
│  ●  ●  •  •  •  •  •         │
└──────────────────────────────┘
```

Bottom-sheet on tap shows the full day detail.

---

## Day cell visual states

| State | Visual |
|---|---|
| Empty (no log, no prediction) | Phase color ring at low opacity, date number in `bloom-ink-soft` |
| Logged flow | Filled circle in flow color (deeper red for heavy, lighter for spotting) |
| Logged symptoms only (no flow) | Small dot below date number |
| Logged mood only | Small mood dot below date number |
| Today | Rose ring outline (1.5px) around the cell |
| Predicted period | Dashed rose ring around the cell |
| Predicted ovulation | Small filled sage dot inside the cell |
| Pending sync | Subtle pulsing animation |
| Out of current month (prev/next month overflow rows) | 40% opacity |

A cell can layer multiple states: today + logged flow + has note → rose ring + filled circle + tiny note indicator (e.g., a small dot on the corner).

### Period range bar (Phase 2 polish — flag for later)

When ≥2 consecutive days have logged flow, draw a soft connecting bar across them (like Apple Health). Improves visual scanability. Can ship without; add as polish.

---

## Cell data model

```dart
class CalendarDay {
  final Date date;
  final bool isInDisplayedMonth;
  final bool isToday;
  final CyclePhase phase;
  final FlowLevel? flow;
  final bool hasSymptoms;
  final bool hasMood;
  final bool hasOwnerNote;
  final bool hasPartnerNote;
  final bool isPredictedPeriod;
  final bool isPredictedOvulation;
  final bool isPendingSync;
}
```

Derived by a pure function:

```dart
List<CalendarDay> buildCalendarDays({
  required Date monthAnchor,
  required List<Cycle> cyclesIntersectingMonth,
  required Map<Date, DayLog> dayLogsForMonth,
  required PredictionOutput? prediction,
  required Date today,
});
```

Pure → unit-testable, fast, memoizable.

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | Calendar shows the displayed month + 1 row of overflow days from prev/next month for visual continuity. |
| BR-2 | Phase coloring is computed per day from cycle data and the prediction. |
| BR-3 | Predicted dates render with dashed/lighter visuals; logged dates render solid. |
| BR-4 | Tapping a day opens the day-detail bottom sheet — same UI as the Today log sheet, scoped to that date. |
| BR-5 | Long-press a day (owner only) opens the cycle-edit menu: "Edit cycle dates" → enters CycleEditor flow. |
| BR-6 | Partner long-press is a no-op (no edit affordances). Tap still opens read-only day detail with `partnerNote` field editable. |
| BR-7 | Future months show predicted dates only; logged data is empty. |
| BR-8 | Months prior to onboarding's `lastPeriodStart` show no data (we don't backfill predictions before the first cycle). |
| BR-9 | Swiping between months feels infinite, but data load is per-month. Adjacent months are pre-fetched as a buffer. |
| BR-10 | Today pill returns to today's month with a smooth animation. |

---

## State machine — `CalendarCubit`

```
[Initial] ──load(month)──> [Loading] ──ok──> [Loaded(month, days)]
                                       └──err──> [Error]

[Loaded] ──changeMonth(dir)──> [Loading] ──ok──> [Loaded(newMonth, days)]
[Loaded] ──jumpToToday──> [Loading] ──ok──> [Loaded]
[Loaded] ──streamUpdate──> [Loaded(sameMonth, updatedDays)]   // when underlying logs/cycles change
```

State payload:
```dart
class CalendarLoaded {
  final Date monthAnchor;            // first of the displayed month
  final List<CalendarDay> days;      // 42 cells (6 × 7)
  final bool isToday;                // true if displayed month contains today
  final bool hasPendingWrites;
}
```

---

## Repository inputs

The cubit composes data from existing repositories — no new contract:

- `CycleRepository.watchRecentCycles(coupleId, limit: 24)` — for phase computation
- `DayLogRepository.watchRange(coupleId, monthStart - 7d, monthEnd + 7d)` — buffered DayLog stream
- Current cycle's `prediction` (denormalized on the cycle doc)

The 7-day buffer accommodates phase transitions across month boundaries.

---

## Performance

- `buildCalendarDays` memoized per `(monthAnchor, cyclesHash, dayLogsHash, predictionHash)`.
- Phase computation is O(1) per day — branch on cycle position.
- Page swipes are buttery via `PageView` with month pages, each `KeepAlive`.
- Initial load: cap historical cycle fetch to 24 (covers ~2 years).
- For monthly buffer: pre-fetch month ±1 in background, evict beyond ±2.

Target: 60fps swipe, < 50ms cell rebuild on data update.

---

## Day detail bottom sheet

Shared with Today's log sheet but scoped to the tapped date:

- Read mode (default for past/future, partner view): shows logged data, no editing of cycle data; `partnerNote` editable.
- Edit mode (owner, present-or-past dates): same fields as Today's log sheet — flow, symptoms, mood, note.
- Cycle controls (owner only):
  - "This day starts a new cycle" — explicit shortcut
  - "Period ended on this day" — sets `currentCycle.periodEndDate`
  - "Edit cycle dates" — opens CycleEditor

Future dates: read-only (you can't log the future). Partner sees their note field but no other affordances.

---

## Edge cases

1. **Empty data (first launch post-onboarding)** — only the first cycle's data is shown; rest is unstyled.
2. **Month boundary spans cycle boundary** — phase changes mid-month, cells render correctly per date.
3. **Future months** — predicted dates only; cells beyond `predictedNextStart + 60d` show no styling (we don't predict that far).
4. **Cycle longer than 45 days (data anomaly)** — cell coloring continues but predictions become unreliable; prediction card on Today shows LOW confidence.
5. **Long-press by partner** — no-op (gesture detector returns false).
6. **Two devices editing the same day** — Firestore stream emits the merged result; UI re-renders.
7. **Offline** — month renders from Hive cache; pending writes show pulsing animation; cloud-off badge in header.
8. **Locale switch** — weekday header re-renders, dates re-format. No data refetch needed.

---

## Test plan

- `buildCalendarDays` — pure unit tests covering all 8 visual states
- `CalendarCubit` transitions — load, changeMonth, jumpToToday
- Edge cases 1–8 each get a named test
- Widget tests:
  - Owner sees long-press menu, partner does not
  - Tap opens day detail sheet for both roles
  - Today pill returns to current month
- Performance: month build < 50ms with 12 months of data, profiled in `flutter test --profile`
- Visual regression: golden tests for each cell state combination
