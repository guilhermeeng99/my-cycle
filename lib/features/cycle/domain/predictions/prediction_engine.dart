import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/utils/dates.dart';

class PredictionInput extends Equatable {
  const PredictionInput({
    required this.historicalCycles,
    required this.currentCycle,
    required this.defaultCycleLength,
    required this.defaultLutealLength,
    required this.today,
  });

  /// Closed cycles ordered **most-recent-first**.
  final List<Cycle> historicalCycles;
  final Cycle currentCycle;
  final int defaultCycleLength;
  final int defaultLutealLength;
  final DateTime today;

  @override
  List<Object?> get props => [
        historicalCycles,
        currentCycle,
        defaultCycleLength,
        defaultLutealLength,
        today,
      ];
}

class PredictionOutput extends Equatable {
  const PredictionOutput({
    required this.predictedNextStart,
    required this.predictedNextStartRangeEnd,
    required this.predictedOvulation,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.confidence,
    required this.confidenceReason,
    required this.sampleSize,
  });

  final DateTime predictedNextStart;
  final DateTime predictedNextStartRangeEnd;
  final DateTime predictedOvulation;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final ConfidenceLevel confidence;
  final String confidenceReason;
  final int sampleSize;

  @override
  List<Object?> get props => [
        predictedNextStart,
        predictedNextStartRangeEnd,
        predictedOvulation,
        fertileWindowStart,
        fertileWindowEnd,
        confidence,
        confidenceReason,
        sampleSize,
      ];
}

/// Pure prediction logic — see `specs/predictions.md` for the full algorithm.
///
/// Returns `null` only when the input has no current cycle whose anchor we
/// can use (caller should never call into here without a current cycle).
abstract final class PredictionEngine {
  /// Threshold beyond which the current cycle is considered "very late" and
  /// the prediction is downgraded to LOW with a stale-data reason.
  static const double _lateMultiplier = 1.5;

  /// Cycles used as input when in Stage D.
  static const int _stageDWindow = 12;

  /// Outlier rejection threshold in standard deviations.
  static const double _outlierStdDevs = 2;

  /// Fertile window length in days (`[ovulation - 5d, ovulation]` inclusive).
  static const int _fertileLeadDays = 5;

  static PredictionOutput compute(PredictionInput input) {
    final stage = _selectStage(input.historicalCycles.length);

    final result = switch (stage) {
      _Stage.a => _stageA(input),
      _Stage.b => _stageB(input),
      _Stage.c => _stageC(input),
      _Stage.d => _stageD(input),
    };

    final capped = _maybeCapConfidence(input, result);
    return _maybeMarkVeryLate(input, capped);
  }

  // ───── stages ─────────────────────────────────────────────────────

  static PredictionOutput _stageA(PredictionInput input) {
    return _build(
      input: input,
      predictedLength: input.defaultCycleLength.toDouble(),
      rangeDays: 2,
      confidence: ConfidenceLevel.low,
      confidenceReason: 'Based on your onboarding info — '
          'log a few cycles for more accurate predictions',
      sampleSize: 0,
    );
  }

  static PredictionOutput _stageB(PredictionInput input) {
    final cycles = input.historicalCycles;
    final weighted = _weightedAverage(
      _lengths(cycles),
      _positionalWeights(cycles.length),
    );
    return _build(
      input: input,
      predictedLength: weighted,
      rangeDays: 2,
      confidence: ConfidenceLevel.low,
      confidenceReason: cycles.length == 1
          ? 'Based on your last cycle — more data improves accuracy'
          : 'Based on your last ${cycles.length} cycles — '
              'more data improves accuracy',
      sampleSize: cycles.length,
    );
  }

  static PredictionOutput _stageC(PredictionInput input) {
    final cycles = input.historicalCycles;
    final lengths = _lengths(cycles);
    final weighted = _weightedAverage(
      lengths,
      _positionalWeights(cycles.length),
    );
    final variance = _stdDev(lengths);
    final range = math.max(2, variance.round());
    return _build(
      input: input,
      predictedLength: weighted,
      rangeDays: range,
      confidence: ConfidenceLevel.medium,
      confidenceReason: 'Based on your last ${cycles.length} cycles',
      sampleSize: cycles.length,
    );
  }

  static PredictionOutput _stageD(PredictionInput input) {
    final cycles = input.historicalCycles;
    final window = cycles.take(_stageDWindow).toList();
    final lengths = _lengths(window);
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final stdev = _stdDev(lengths);

    final filteredCycles = <Cycle>[];
    final filteredLengths = <int>[];
    for (var i = 0; i < window.length; i++) {
      if ((lengths[i] - mean).abs() <= _outlierStdDevs * stdev) {
        filteredCycles.add(window[i]);
        filteredLengths.add(lengths[i]);
      }
    }
    final excluded = window.length - filteredCycles.length;

    final weights = _positionalWeights(filteredCycles.length);
    for (var i = 0; i < filteredCycles.length; i++) {
      if (_isOlderThan12Months(filteredCycles[i], input.today)) {
        weights[i] *= 0.5;
      }
    }
    final weighted = _weightedAverage(filteredLengths, weights);
    final variance = _stdDev(filteredLengths);
    final range = math.max(1, variance.round());

    return _build(
      input: input,
      predictedLength: weighted,
      rangeDays: range,
      confidence: ConfidenceLevel.high,
      confidenceReason: excluded > 0
          ? 'Based on your last ${filteredCycles.length} cycles '
              '($excluded unusual cycle${excluded == 1 ? '' : 's'} excluded)'
          : 'Based on your last ${filteredCycles.length} cycles',
      sampleSize: filteredCycles.length,
    );
  }

  // ───── shared builder ─────────────────────────────────────────────

  static PredictionOutput _build({
    required PredictionInput input,
    required double predictedLength,
    required int rangeDays,
    required ConfidenceLevel confidence,
    required String confidenceReason,
    required int sampleSize,
  }) {
    final start = normalizeDate(input.currentCycle.startDate);
    final base = start.add(Duration(days: predictedLength.round()));
    final earliest = base.subtract(Duration(days: rangeDays));
    final latest = base.add(Duration(days: rangeDays));
    final ovulation = base.subtract(Duration(days: input.defaultLutealLength));
    final fertileStart =
        ovulation.subtract(const Duration(days: _fertileLeadDays));
    return PredictionOutput(
      predictedNextStart: earliest,
      predictedNextStartRangeEnd: latest,
      predictedOvulation: ovulation,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: ovulation,
      confidence: confidence,
      confidenceReason: confidenceReason,
      sampleSize: sampleSize,
    );
  }

  // ───── post-processing ────────────────────────────────────────────

  /// If the data spans less than 6 months, cap confidence at MEDIUM.
  static PredictionOutput _maybeCapConfidence(
    PredictionInput input,
    PredictionOutput output,
  ) {
    if (output.confidence != ConfidenceLevel.high) return output;
    final cycles = input.historicalCycles;
    if (cycles.isEmpty) return output;
    final oldest = cycles.last;
    final spanDays = daysBetween(oldest.startDate, input.today);
    if (spanDays < 180) {
      return PredictionOutput(
        predictedNextStart: output.predictedNextStart,
        predictedNextStartRangeEnd: output.predictedNextStartRangeEnd,
        predictedOvulation: output.predictedOvulation,
        fertileWindowStart: output.fertileWindowStart,
        fertileWindowEnd: output.fertileWindowEnd,
        confidence: ConfidenceLevel.medium,
        confidenceReason: output.confidenceReason,
        sampleSize: output.sampleSize,
      );
    }
    return output;
  }

  /// If the current cycle is past the predicted length × 1.5, the prediction
  /// is stale — downgrade to LOW with a guidance message.
  static PredictionOutput _maybeMarkVeryLate(
    PredictionInput input,
    PredictionOutput output,
  ) {
    final start = normalizeDate(input.currentCycle.startDate);
    final today = normalizeDate(input.today);
    final dayN = daysBetween(start, today);
    // Restore the midpoint of the range (we subtracted rangeDays in _build).
    final rangeWidth = daysBetween(
      output.predictedNextStart,
      output.predictedNextStartRangeEnd,
    );
    final predictedLength =
        daysBetween(start, output.predictedNextStart) + rangeWidth ~/ 2;
    if (dayN > predictedLength * _lateMultiplier) {
      final lateBy = dayN - predictedLength;
      return PredictionOutput(
        predictedNextStart: output.predictedNextStart,
        predictedNextStartRangeEnd: output.predictedNextStartRangeEnd,
        predictedOvulation: output.predictedOvulation,
        fertileWindowStart: output.fertileWindowStart,
        fertileWindowEnd: output.fertileWindowEnd,
        confidence: ConfidenceLevel.low,
        confidenceReason:
            'Period seems late by $lateBy days — log flow to start a new cycle',
        sampleSize: output.sampleSize,
      );
    }
    return output;
  }

  // ───── helpers ────────────────────────────────────────────────────

  static List<int> _lengths(List<Cycle> cycles) {
    return cycles.map((c) => c.totalLengthDays!).toList();
  }

  /// `[N, N-1, ..., 1]` so the newest cycle (index 0) gets the highest weight.
  static List<double> _positionalWeights(int n) {
    return List<double>.generate(n, (i) => (n - i).toDouble());
  }

  static double _weightedAverage(List<int> values, List<double> weights) {
    double weightedSum = 0;
    double totalWeight = 0;
    for (var i = 0; i < values.length; i++) {
      weightedSum += values[i] * weights[i];
      totalWeight += weights[i];
    }
    return weightedSum / totalWeight;
  }

  static double _stdDev(List<int> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSqDiff = values
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b);
    return math.sqrt(sumSqDiff / values.length);
  }

  static bool _isOlderThan12Months(Cycle cycle, DateTime today) {
    return daysBetween(cycle.startDate, today) > 365;
  }

  static _Stage _selectStage(int historicalCount) {
    if (historicalCount == 0) return _Stage.a;
    if (historicalCount <= 2) return _Stage.b;
    if (historicalCount <= 5) return _Stage.c;
    return _Stage.d;
  }
}

enum _Stage { a, b, c, d }
