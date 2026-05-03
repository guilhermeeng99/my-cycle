import 'package:flutter_test/flutter_test.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/utils/dates.dart';
import 'package:mycycle/features/cycle/domain/predictions/prediction_engine.dart';

import '../../../../harness/factories/cycle_factory.dart';
import '../../../../harness/factories/user_factory.dart';

void main() {
  // Pinned reference dates for reproducibility.
  final today = DateTime.utc(2026, 5, 3);
  final cycleStart = DateTime.utc(2026, 4, 19); // 14 days into the cycle today

  Cycle currentCycle({DateTime? start}) => CycleFactory.make(
        id: 'current',
        startDate: start ?? cycleStart,
      );

  /// Builds a list of historical cycles, oldest-last (most-recent-first).
  /// [lengths] is in chronological order (oldest first); we reverse so the
  /// resulting list matches the engine's contract.
  List<Cycle> historicalCycles({
    required List<int> lengthsChronological,
    DateTime? oldestStartDate,
  }) {
    final cycles = <Cycle>[];
    var start = oldestStartDate ??
        cycleStart.subtract(
          Duration(
            days: lengthsChronological.fold<int>(0, (a, b) => a + b),
          ),
        );
    for (var i = 0; i < lengthsChronological.length; i++) {
      final len = lengthsChronological[i];
      cycles.add(
        CycleFactory.make(
          id: 'h$i',
          startDate: start,
          totalLengthDays: len,
        ),
      );
      start = start.add(Duration(days: len));
    }
    return cycles.reversed.toList(); // most-recent first
  }

  PredictionInput buildInput({
    List<Cycle> historical = const <Cycle>[],
    int defaultCycleLength = 28,
    int defaultLutealLength = 14,
    Cycle? currentOverride,
  }) {
    return PredictionInput(
      historicalCycles: historical,
      currentCycle: currentOverride ?? currentCycle(),
      defaultCycleLength: defaultCycleLength,
      defaultLutealLength: defaultLutealLength,
      today: today,
    );
  }

  group('Stage A — 0 historical cycles', () {
    test('uses defaultCycleLength to position the predicted next start', () {
      final out = PredictionEngine.compute(buildInput());
      // baseDate = cycleStart + 28 days = May 17. Range ±2 → [May 15, May 19].
      expect(out.predictedNextStart, DateTime.utc(2026, 5, 15));
      expect(out.predictedNextStartRangeEnd, DateTime.utc(2026, 5, 19));
    });

    test('confidence is LOW with sampleSize 0', () {
      final out = PredictionEngine.compute(buildInput());
      expect(out.confidence, ConfidenceLevel.low);
      expect(out.sampleSize, 0);
      expect(out.confidenceReason, contains('onboarding'));
    });

    test('ovulation = baseDate − defaultLutealLength', () {
      final out = PredictionEngine.compute(buildInput());
      // baseDate = May 17, ovulation = baseDate - 14 = May 3.
      expect(out.predictedOvulation, DateTime.utc(2026, 5, 3));
    });

    test('fertile window is exactly 6 days wide', () {
      final out = PredictionEngine.compute(buildInput());
      final width = daysBetween(
        out.fertileWindowStart,
        out.fertileWindowEnd,
      );
      expect(width, 5); // 5 days difference = 6 inclusive days
    });
  });

  group('Stage B — 1 to 2 historical cycles', () {
    test('weighted average favors the most recent cycle', () {
      // older = 26, newer = 30. With weights [1, 2] (newer = 2):
      // weighted = (26*1 + 30*2) / 3 = 86/3 ≈ 28.67 → 29
      final out = PredictionEngine.compute(
        buildInput(
          historical: historicalCycles(
            lengthsChronological: [26, 30],
          ),
        ),
      );
      // baseDate = cycleStart + 29 = Apr 19 + 29 = May 18. Range ±2.
      expect(out.predictedNextStart, DateTime.utc(2026, 5, 16));
      expect(out.predictedNextStartRangeEnd, DateTime.utc(2026, 5, 20));
    });

    test('range is always ±2 days in Stage B', () {
      final out = PredictionEngine.compute(
        buildInput(
          historical: historicalCycles(lengthsChronological: [28, 28]),
        ),
      );
      final width = daysBetween(
        out.predictedNextStart,
        out.predictedNextStartRangeEnd,
      );
      expect(width, 4); // ±2 around the base = 5 days inclusive (4 days diff)
    });

    test('confidence stays LOW for 1 cycle', () {
      final out = PredictionEngine.compute(
        buildInput(
          historical: historicalCycles(lengthsChronological: [28]),
        ),
      );
      expect(out.confidence, ConfidenceLevel.low);
      expect(out.sampleSize, 1);
    });
  });

  group('Stage C — 3 to 5 historical cycles', () {
    test('confidence is MEDIUM and reason mentions cycle count', () {
      final out = PredictionEngine.compute(
        buildInput(
          historical: historicalCycles(
            lengthsChronological: [28, 28, 28, 28],
          ),
        ),
      );
      expect(out.confidence, ConfidenceLevel.medium);
      expect(out.sampleSize, 4);
      expect(out.confidenceReason, contains('4 cycles'));
    });

    test('high variance widens the range', () {
      // Mean ≈ 28, but spread is wide (24, 28, 32, 36). stddev > 2.
      final tightOut = PredictionEngine.compute(
        buildInput(
          historical: historicalCycles(
            lengthsChronological: [28, 28, 28, 28],
          ),
        ),
      );
      final wideOut = PredictionEngine.compute(
        buildInput(
          historical: historicalCycles(
            lengthsChronological: [22, 30, 22, 34],
          ),
        ),
      );

      final tightWidth = daysBetween(
        tightOut.predictedNextStart,
        tightOut.predictedNextStartRangeEnd,
      );
      final wideWidth = daysBetween(
        wideOut.predictedNextStart,
        wideOut.predictedNextStartRangeEnd,
      );

      expect(wideWidth, greaterThan(tightWidth));
    });
  });

  group('Stage D — 6+ historical cycles', () {
    test('confidence is HIGH (when data spans ≥ 6 months)', () {
      // 8 cycles × 28 days = 224 days span > 180.
      final cycles = historicalCycles(
        lengthsChronological: List<int>.filled(8, 28),
      );
      final out = PredictionEngine.compute(
        buildInput(historical: cycles),
      );
      expect(out.confidence, ConfidenceLevel.high);
    });

    test('outliers more than 2σ from the mean are excluded', () {
      // Most cycles ~28 with one wild outlier (50). The outlier should be
      // dropped — confidenceReason should mention the exclusion.
      final cycles = historicalCycles(
        lengthsChronological: [28, 28, 28, 28, 28, 28, 28, 50],
      );
      final out = PredictionEngine.compute(
        buildInput(historical: cycles),
      );
      expect(out.confidenceReason, contains('excluded'));
    });

    test('range can tighten to ±1 with very consistent cycles', () {
      // Identical cycles → stddev = 0 → range = max(1, 0) = ±1.
      final cycles = historicalCycles(
        lengthsChronological: List<int>.filled(8, 28),
      );
      final out = PredictionEngine.compute(
        buildInput(historical: cycles),
      );
      final width = daysBetween(
        out.predictedNextStart,
        out.predictedNextStartRangeEnd,
      );
      expect(width, 2); // ±1 → 3 days inclusive (2-day diff)
    });
  });

  group('Confidence cap', () {
    test('caps at MEDIUM when data spans less than 6 months', () {
      // 6 short cycles → only ~120 days span, < 180.
      final cycles = historicalCycles(
        lengthsChronological: List<int>.filled(6, 20),
      );
      final out = PredictionEngine.compute(
        buildInput(historical: cycles),
      );
      expect(out.confidence, ConfidenceLevel.medium);
    });
  });

  group('Very-late override', () {
    test('downgrades to LOW with stale-data reason', () {
      // Force "today" to be way past the predicted period (1.5x cycle length).
      final manyDaysLater = DateTime.utc(2026, 5, 7);
      final start = manyDaysLater.subtract(const Duration(days: 90));
      final input = PredictionInput(
        historicalCycles: const <Cycle>[],
        currentCycle: CycleFactory.make(id: 'late', startDate: start),
        defaultCycleLength: 28,
        defaultLutealLength: 14,
        today: manyDaysLater,
      );
      final out = PredictionEngine.compute(input);
      expect(out.confidence, ConfidenceLevel.low);
      expect(out.confidenceReason, contains('late'));
    });
  });

  group('Properties', () {
    test('predictedOvulation = baseDate − defaultLutealLength always', () {
      final out = PredictionEngine.compute(
        buildInput(defaultLutealLength: 12),
      );
      // baseDate is the midpoint of the predicted-next-start range. With
      // ±2 the midpoint is predictedNextStart + 2 days. Ovulation = base - 12.
      final base = out.predictedNextStart.add(const Duration(days: 2));
      final expectedOv = base.subtract(const Duration(days: 12));
      expect(out.predictedOvulation, expectedOv);
    });

    test('fertileWindow always 6 days inclusive', () {
      final outs = <PredictionOutput>[
        PredictionEngine.compute(buildInput()),
        PredictionEngine.compute(
          buildInput(
            historical: historicalCycles(lengthsChronological: [28, 28, 28]),
          ),
        ),
      ];
      for (final out in outs) {
        final width = daysBetween(
          out.fertileWindowStart,
          out.fertileWindowEnd,
        );
        expect(width, 5, reason: 'expected 6 inclusive days');
      }
    });
  });

  // Touch the user factory so the harness imports are exercised — keeps
  // unused-import lint happy while we wait for shared fixtures.
  test('user factory smoke', () {
    expect(UserFactory.unpaired().id, isNotEmpty);
  });
}
