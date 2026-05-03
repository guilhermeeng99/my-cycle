# Insights — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

The Insights tab surfaces patterns over time: averages, regularity, next prediction. Read-only — no logging or editing happens here.

---

## Goals

1. Make the prediction engine visible. Today it's used internally by Today and Calendar but never shown as an explicit "next period: range × confidence" card.
2. Honest summaries. No vanity metrics. Sample size is always shown.
3. Calm, journal-like layout. No vibrant charts; soft cycle-phase colors only.

Non-goals: charts, week-by-week graphs, fertility predictions for conception. Those are deliberate omissions to keep the surface honest and bounded.

---

## Sections (in render order)

1. **Next prediction** *(rendered only when there is a current cycle)*
   - Date range: `predictedNextStart` – `predictedNextStartRangeEnd`
   - Ovulation date estimate
   - Confidence pill (low / medium / high) with phase color
2. **Your averages** *(always shown when at least one closed cycle exists)*
   - Average cycle length (days)
   - Average period length (days)
3. **Regularity** *(rendered when ≥ 3 closed cycles)*
   - Bucket label: very steady / mostly steady / quite variable
   - Bar fill (1.0 / 0.66 / 0.33)
   - "Based on the last N closed cycles." hint
4. **Sample size footer** — total tracked cycles count

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | Insights MUST NOT render anything if there are zero closed cycles AND no current cycle. Show empty-state instead. |
| BR-2 | Averages render once at least one closed cycle exists. Period-length average is conditional on `periodEndDate` being set. |
| BR-3 | Regularity requires ≥ 3 closed cycles (`InsightsCubit._regularityFor` returns null below that). |
| BR-4 | Next prediction is rendered when a current cycle exists. The prediction is computed via `PredictionEngine.compute` — the same engine used everywhere else, no parallel implementation. |
| BR-5 | Confidence MUST be displayed when a prediction is shown. Predictions never appear without a confidence label. |
| BR-6 | The page is always read-only. Tapping a card does NOT open an editor. (Future: tap to see the explanation behind the calculation.) |

---

## Regularity bucket cutoffs

```dart
final stdDev = sqrt(variance);
if (stdDev <= 2) return Regularity.high;     // very steady
if (stdDev <= 4) return Regularity.medium;   // mostly steady
return Regularity.low;                        // quite variable
```

Picked from typical clinical ranges. σ ≤ 2 days is unusually steady; σ between 2–4 days is the norm; σ > 4 days warrants the variability label.

---

## State machine — `InsightsCubit`

```
[Loading] ──first couple+cycles emission──> [Empty]    if no cycles at all
                                          └ [Loaded]  otherwise

[Loaded] ──repository emits new cycles──> [Loaded(updated stats)]
[Loaded] ──repository emits new couple defaults──> [Loaded(re-predicted)]
```

`Loading` is the initial state. The cubit subscribes to `coupleRepository.watchCouple` and `cycleRepository.watchRecentCycles` in its constructor; only emits a `Loaded` state once both streams have produced at least one value.

---

## Repository contract

No new repository — Insights re-uses `CycleRepository.watchRecentCycles` and `CoupleRepository.watchCouple`. Predictions go through the existing `PredictionEngine` pure function.

---

## Edge cases

1. **Couple loaded, cycles list still loading** — stay on `Loading` until both have emitted.
2. **No closed cycles, but current cycle exists** — render only Next Prediction (Stage A from the engine — defaults-based, low confidence). Averages and Regularity are hidden.
3. **One closed cycle** — averages render; regularity hidden.
4. **Closed cycles without `periodEndDate`** — period-length average shows "—" if no closed cycle had its period end recorded.
5. **Prediction confidence is downgraded by `_maybeMarkVeryLate`** — the pill color follows the engine's final confidence; we do not second-guess.
6. **Empty state** — shown when both `closed.isEmpty && current == null`. Clear copy: "Log a few cycles and your patterns will appear here…"

---

## Test plan

- Initial state is `InsightsLoading`.
- Empty couple + empty cycles → `InsightsEmpty`.
- Loaded with closed cycles only → averages computed, regularity null when n < 3.
- Loaded with ≥ 3 closed cycles → regularity bucket reflects std-dev cutoffs.
- Loaded with current cycle → `prediction != null` and goes through `PredictionEngine.compute`.
- Re-emits on couple update (e.g., `defaultCycleLength` change) — re-runs prediction.
