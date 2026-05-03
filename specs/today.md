# Today — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

The Today screen is the daily-driver: phase, day count, log CTA, and (for partners) a read-mostly companion view. Two layouts driven by `User.role`, one shared cubit.

---

## Owner view (wife)

Layout, top to bottom:

1. **App bar** — greeting (`"Bom dia, [name]"`), profile avatar (taps to Settings)
2. **CycleRing** (hero, full-width) — animated circular ring, phase quadrants colored, today's position marked, breathing pulse animation
3. **Phase card** — phase name + 1-line "what to expect" copy
4. **"Log today" CTA** — primary button, opens bottom sheet with flow + symptoms + mood selectors
5. **Recent days strip** — horizontal row of last 7 days as small cells with phase color + log indicators
6. **Prediction card** — "Next period around Mar 14–16" + confidence pill
7. **Late banner** (conditional) — appears when 3+ days late: "Late by N days. Log flow when it starts."

### Owner micro-interactions

- Tap phase card → phase detail bottom sheet (longer copy + "what's normal" tips)
- Tap recent day cell → day detail bottom sheet (full DayLog editor)
- Tap prediction card → transparency modal (see `predictions.md` § Display rules)
- Long-press CycleRing → calendar (visual handoff to the hero feature)
- Pull-to-refresh: forces stream re-fetch (defensive against subscription drops)

---

## Partner view (husband)

Same data, different surface. Read-mostly with a small write-affordance.

Layout, top to bottom:

1. **App bar** — greeting (`"Olá, [partner name]"`), profile avatar
2. **CycleRing** (read-only, smaller) — phase visible, day count visible, no animation pulse
3. **"How she's doing today" card** — summary of today's owner-logged data
   - Flow level (if any)
   - Symptoms (chips, no edit)
   - Mood (if logged)
   - "She hasn't logged today yet" if empty
4. **Owner's note** (if any) — soft card with the `ownerNote` content
5. **Your note** — text field for `partnerNote`. "Leave a note for her" placeholder. Saves on blur with debounce.
6. **Recent days** — last 7 days, read-only, tap to view detail
7. **Prediction card** — same as owner, no controls
8. **Late banner** — same as owner (informational)

### Partner micro-interactions

- Tap day → day detail (read-only owner data + editable `partnerNote` field)
- No long-press affordances (no edit power)

### Partner UX intentions (call out in design review)

- Tone: companion, not surveillance. The wording must read as "supporting" not "tracking."
- No graphs or analytics in partner view at MVP — just today + recent week.
- The partner-note composer is the primary write affordance. Make it inviting.

---

## Shared cubit — `TodayCubit`

One cubit feeds both views. Selects fields per role at the widget level.

```
[Initial] ──load──> [Loading] ──data──> [Loaded(viewModel)]
                              ├──no cycle──> [Empty]   (owner only — partners always have a cycle if paired)
                              └──err──> [Error(failure)]

[Loaded] ──streamUpdate──> [Loaded(updatedVM)]
```

### `TodayViewModel`

```dart
class TodayViewModel {
  final User currentUser;             // determines role at widget level
  final Cycle currentCycle;
  final int dayN;
  final CyclePhase phase;
  final PredictionOutput? prediction;
  final DayLog? todayLog;             // null if nothing logged today
  final List<DayLog> recentLogs;      // last 7 days, including today
  final String? ownerName;            // for partner greeting
  final String? partnerName;          // for owner greeting
  final bool isLatePeriod;            // computed: prediction.predictedNextStart + 3 < today
  final int latenessDays;             // 0 if not late
  final bool isOffline;
  final bool hasPendingWrites;
}
```

The cubit subscribes to:
- `watchCurrentCycle(coupleId)` (cycle-level changes)
- `watchDay(coupleId, today)` (today's DayLog)
- `watchRange(coupleId, today - 7d, today)` (recent logs)
- `watchCouple(coupleId)` (member names, settings)

Combined into the VM via `Rx.combineLatest` or `StreamGroup`.

---

## `LogActionCubit` (driving the bottom sheet)

Lives separately; opened from the "Log today" CTA. See `cycle.md` § State machines for the state diagram (`Idle → Saving → Success/Error`).

The bottom sheet UI:

- Flow level: 4 chips (spotting, light, medium, heavy) — single select, can deselect
- Symptoms: 8 chips (cramps, headache, bloating, fatigue, tenderBreasts, acne, backPain, nausea) — multi-select
- Mood: 5 chips (happy, calm, irritable, sad, anxious) — single select
- Note: optional text field
- "Save" button (primary)

Single submit writes the full DayLog upsert. Optimistic UI: closes the sheet immediately, shows a checkmark toast on confirmed save (or revert + error toast on failure).

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | Today's CycleRing reads only from current cycle. Past cycles are not displayed here (they live in Calendar/Insights). |
| BR-2 | Owner view shows the "Log today" CTA. Partner view does not. |
| BR-3 | Partner view shows a `partnerNote` composer. Owner view does not. |
| BR-4 | Both views show the prediction card identically. |
| BR-5 | Late banner appears only when `today > prediction.predictedNextStart + 3 days` AND no new cycle has started. |
| BR-6 | If `currentCycle` is null (owner only — partner always inherits the couple's cycle): show Empty state with onboarding-style CTA "Log your first period." |
| BR-7 | Pull-to-refresh re-subscribes to streams; otherwise updates are pushed automatically. |
| BR-8 | The partner-note text field debounces 800ms before save. Save indicator: subtle "Saving..." → "Saved ✓". |

---

## Edge cases

1. **No cycle (owner)** → Empty state, log CTA prominent. Partner shouldn't see this state — if they do, it's a data integrity issue (couple has no current cycle).
2. **Cycle ongoing but no DayLogs ever** → Today's log is null; recent days strip is empty. Don't show "she hasn't logged today" for partner — show "No logs yet for this cycle."
3. **Offline** → small cloud-off badge in app bar; UI works from Hive cache; pending writes show a small dot.
4. **Partner views with stale data** → Firestore listener restores within seconds on reconnect.
5. **App opened at 23:59** → `today` rolls to tomorrow at midnight via `Clock` stream. The cubit re-renders.
6. **Just-paired partner with no logs** → "She hasn't logged today yet" + previous days from before pairing are visible (full read access from the moment of pairing).

---

## Test plan

- `TodayCubit` stream combination — emits Loaded with correct VM, re-emits on changes
- `TodayViewModel` derivations: `isLatePeriod`, `latenessDays`, `isOffline`
- Widget tests:
  - Owner widget renders log CTA, no partner-note composer
  - Partner widget renders partner-note composer, no log CTA
  - Both render prediction card identically
- Empty state for owner without cycle
- Late banner appears at exactly 3 days late, not 2
