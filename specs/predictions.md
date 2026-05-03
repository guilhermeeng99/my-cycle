# Predictions — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

The prediction engine computes the next predicted period, ovulation, and fertile window from historical cycle data. It's a **pure function** in the domain layer — no I/O, no side effects, fully testable with `dart test`.

---

## Design principle: honest predictions

Cycle predictions are inherently uncertain. We never display a single predicted date — always a **range with a confidence label**. Users can tap any prediction to see exactly how it was computed. Transparency builds trust.

We refuse to ship predictions that imply false precision.

---

## Inputs

```dart
class PredictionInput {
  final List<Cycle> historicalCycles;     // closed cycles only, ordered most-recent-first
  final Cycle currentCycle;                // the open cycle (totalLengthDays == null)
  final int defaultCycleLength;            // from Couple, used as fallback
  final int defaultLutealLength;           // from Couple, used always for ovulation calc
  final Date today;                        // injected via Clock for testability
}
```

**Why pure?** Lives at `lib/features/cycle/domain/prediction_engine.dart`. Reused by Today screen, Calendar, and notification scheduler. No testability surprises. No Flutter dependency.

---

## Outputs

```dart
class PredictionOutput {
  final Date predictedNextStart;          // range start
  final Date predictedNextStartRangeEnd;  // range end (always >= predictedNextStart)
  final Date predictedOvulation;
  final Date fertileWindowStart;
  final Date fertileWindowEnd;
  final ConfidenceLevel confidence;       // low | medium | high
  final String confidenceReason;          // human-readable explanation, shown in UI
  final int sampleSize;                   // cycles used in the calculation
}

enum ConfidenceLevel { low, medium, high }
```

---

## Algorithm by stage

The algorithm switches strategy based on how many historical (closed) cycles are available.

### Stage A — 0 historical cycles

```
predictedLength = defaultCycleLength
predictedNextStart = currentCycle.startDate + predictedLength
range = ±2 days
predictedOvulation = predictedNextStart - defaultLutealLength
fertileWindow = [predictedOvulation - 5, predictedOvulation]
confidence = LOW
confidenceReason = "Based on your onboarding info — log a few cycles for more accurate predictions"
sampleSize = 0
```

### Stage B — 1 to 2 historical cycles

```
weightedLength = weighted_avg(historicalCycles.lengths)
                 # weight = position from oldest (1, 2, ..., N), so newest weighs N
predictedNextStart = currentCycle.startDate + round(weightedLength)
range = ±2 days
predictedOvulation = predictedNextStart - defaultLutealLength
fertileWindow = [predictedOvulation - 5, predictedOvulation]
confidence = LOW
confidenceReason = "Based on your last {sampleSize} cycle(s) — more data improves accuracy"
sampleSize = historicalCycles.length
```

### Stage C — 3 to 5 historical cycles

```
weightedLength = weighted_avg(historicalCycles.lengths)
predictedNextStart = currentCycle.startDate + round(weightedLength)
variance = stddev(lengths)
range = round(±max(2, variance))   # at least ±2, wider when cycles vary a lot
predictedOvulation = predictedNextStart - defaultLutealLength
fertileWindow = [predictedOvulation - 5, predictedOvulation]
confidence = MEDIUM
confidenceReason = "Based on your last {sampleSize} cycles"
sampleSize = historicalCycles.length
```

### Stage D — 6+ historical cycles

```
N = min(historicalCycles.length, 12)        # use last 12 max
recent = historicalCycles.take(N)

# Outlier rejection
mean = avg(recent.lengths)
stdev = stddev(recent.lengths)
filtered = recent.where(|x - mean| <= 2 * stdev)
excluded = recent.length - filtered.length

# Weighting
#   - newest cycle: weight = filtered.length
#   - oldest in window: weight = 1
#   - cycles older than 12 months: additional 0.5x multiplier
weightedLength = weighted_avg(filtered)
variance = stddev(filtered.lengths)
range = round(±max(1, variance))            # may tighten to ±1 with very consistent data

predictedNextStart = currentCycle.startDate + round(weightedLength)
predictedOvulation = predictedNextStart - defaultLutealLength
fertileWindow = [predictedOvulation - 5, predictedOvulation]
confidence = HIGH                            # high confidence in the *range*, not the date
confidenceReason = excluded > 0
  ? "Based on your last {filtered.length} cycles ({excluded} unusual cycle(s) excluded)"
  : "Based on your last {filtered.length} cycles"
sampleSize = filtered.length
```

### Confidence cap

If logged cycles span less than 6 months total, cap confidence at MEDIUM regardless of count. Six cycles in four months is itself a signal of irregularity worth flagging through the confidence ceiling.

---

## Special cases

### No cycle ever started

Don't return a `PredictionOutput`. Return `null` (or `Result.failure(InsufficientDataFailure)`). UI shows: "Log your first period to see predictions."

### Current cycle is "very late"

If `today > currentCycle.startDate + (predictedLength * 1.5)` and no new cycle has started:

- Stop forecasting future periods. The current prediction is stale and shouldn't pretend otherwise.
- Return a `PredictionOutput` with the original prediction, but `confidence = LOW` and `confidenceReason = "Period seems late by N days — log flow to start a new cycle"`.

### User manually edited a cycle's dates

Trigger a recompute. The edit changes the input set, so all downstream views that listen to predictions update reactively.

---

## Recompute triggers

Predictions are recomputed (and persisted to the current cycle's `predicted*` fields) when:

1. A new cycle starts — most important moment, snapshots the prediction for the new cycle.
2. A cycle's `totalLengthDays` becomes finalized (the next cycle starts and closes it).
3. User edits any cycle's `startDate` or `periodEndDate`.
4. User changes `defaultLutealLength` in settings.
5. App cold-start — recomputes once for the current cycle, in case the algorithm was updated between sessions.

The current cycle's predicted fields are denormalized into the document for fast reads. The pure function is the source of truth; the persisted fields are a cache.

---

## Display rules

| Element | Format |
|---|---|
| Headline prediction | "Around {Mar 14}–{16}" — never a single date |
| Confidence label | Pill next to prediction, color-coded: low (`whisper`), medium (`honey`), high (`sage`) |
| Tap action | Modal: `sampleSize`, `excluded` count if any, `weightedLength` used, `defaultLutealLength` used |
| Stale (very late) state | Banner overlays prediction: "Period seems late by {n} days" |

The transparency modal is critical — it converts the algorithm from a black box into a visible, trustworthy thing. Implementation note: the modal renders the same `confidenceReason` plus a small breakdown table.

---

## Test plan

```dart
// Pure function tests — no Flutter, no I/O
group('PredictionEngine', () {
  test('Stage A: 0 historical cycles uses default cycle length');
  test('Stage A: confidence is LOW with sampleSize 0');

  test('Stage B: weighted average favors recent cycles');
  test('Stage B: range is always ±2 days');

  test('Stage C: variance widens the range');
  test('Stage C: confidence is MEDIUM');

  test('Stage D: outliers >2σ are excluded');
  test('Stage D: cycles older than 12 months are down-weighted 0.5x');
  test('Stage D: range can tighten to ±1 with low variance');
  test('Stage D: confidenceReason mentions excluded count when > 0');

  test('Confidence caps at MEDIUM when data spans < 6 months');

  test('Very late current cycle returns LOW confidence with stale message');
  test('No cycles at all returns null/InsufficientDataFailure');

  test('Manual cycle edit produces updated output');

  // Property tests
  test('predicted range always contains the weighted average');
  test('predictedOvulation = predictedNextStart - defaultLutealLength always');
  test('fertileWindow is exactly 6 days wide');
});
```

---

## Out of scope (Phase 2+)

- Bayesian update from symptom severity (cervical mucus, BBT)
- LH-test or fertility-monitor integration
- Cycle phase predictions for irregular cycles (PCOS, post-pill, perimenopause)
- ML-based prediction
