import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/features/cycle/domain/predictions/prediction_engine.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';

/// Surface for the Insights tab.
///
/// Subscribes to the couple + recent cycles stream, computes summary stats
/// (averages, regularity, next prediction) and emits a single immutable
/// view-model the page renders.
class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({
    required String coupleId,
    required CycleRepository cycleRepository,
    required CoupleRepository coupleRepository,
    required Clock clock,
  }) : _cycleRepository = cycleRepository,
       _coupleRepository = coupleRepository,
       _coupleId = coupleId,
       _clock = clock,
       super(const InsightsLoading()) {
    _coupleSub = _coupleRepository.watchCouple(_coupleId).listen(_onCouple);
    _cyclesSub = _cycleRepository
        .watchRecentCycles(_coupleId)
        .listen(_onCycles);
  }

  final CycleRepository _cycleRepository;
  final CoupleRepository _coupleRepository;
  final String _coupleId;
  final Clock _clock;

  StreamSubscription<Couple?>? _coupleSub;
  StreamSubscription<List<Cycle>>? _cyclesSub;

  Couple? _couple;
  List<Cycle>? _cycles;

  void _onCouple(Couple? couple) {
    _couple = couple;
    _recompute();
  }

  void _onCycles(List<Cycle> cycles) {
    _cycles = cycles;
    _recompute();
  }

  void _recompute() {
    final couple = _couple;
    final cycles = _cycles;
    if (couple == null || cycles == null) return;

    final closed = cycles.where((c) => !c.isCurrent).toList();
    final current = cycles.firstWhereOrNull((c) => c.isCurrent);

    if (closed.isEmpty && current == null) {
      emit(const InsightsEmpty());
      return;
    }

    final averageCycleDays = closed.isEmpty
        ? null
        : closed
                  .map((c) => c.totalLengthDays!)
                  .reduce((a, b) => a + b) /
              closed.length;

    final periodLengths = closed
        .where((c) => c.periodEndDate != null)
        .map(
          (c) => c.periodEndDate!.difference(c.startDate).inDays + 1,
        )
        .toList();
    final averagePeriodDays = periodLengths.isEmpty
        ? null
        : periodLengths.reduce((a, b) => a + b) / periodLengths.length;

    final regularity = closed.length < 3
        ? null
        : _regularityFor(closed.map((c) => c.totalLengthDays!).toList());

    final prediction = current == null
        ? null
        : PredictionEngine.compute(
            PredictionInput(
              historicalCycles: closed,
              currentCycle: current,
              defaultCycleLength: couple.defaultCycleLength,
              defaultLutealLength: couple.defaultLutealLength,
              today: _clock.now(),
            ),
          );

    emit(
      InsightsLoaded(
        averageCycleDays: averageCycleDays,
        averagePeriodDays: averagePeriodDays,
        regularity: regularity,
        regularitySampleSize: closed.length,
        prediction: prediction,
        totalTrackedCycles: closed.length,
      ),
    );
  }

  /// Maps cycle-length standard deviation to a 3-bucket label. The cutoffs
  /// were picked from typical clinical ranges: σ≤2d is steady, σ≤4d is
  /// mostly-steady, beyond is variable.
  Regularity _regularityFor(List<int> lengths) {
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final squaredDiffs = lengths.map((l) => math.pow(l - mean, 2).toDouble());
    final variance =
        squaredDiffs.reduce((a, b) => a + b) / lengths.length;
    final stdDev = math.sqrt(variance);
    if (stdDev <= 2) return Regularity.high;
    if (stdDev <= 4) return Regularity.medium;
    return Regularity.low;
  }

  @override
  Future<void> close() async {
    await _coupleSub?.cancel();
    await _cyclesSub?.cancel();
    return super.close();
  }
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}

enum Regularity { low, medium, high }

sealed class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => <Object?>[];
}

final class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

/// No closed cycles AND no current cycle — nothing to show yet.
final class InsightsEmpty extends InsightsState {
  const InsightsEmpty();
}

final class InsightsLoaded extends InsightsState {
  const InsightsLoaded({
    required this.regularitySampleSize,
    required this.totalTrackedCycles,
    this.averageCycleDays,
    this.averagePeriodDays,
    this.regularity,
    this.prediction,
  });

  final double? averageCycleDays;
  final double? averagePeriodDays;
  final Regularity? regularity;
  final int regularitySampleSize;
  final PredictionOutput? prediction;
  final int totalTrackedCycles;

  @override
  List<Object?> get props => <Object?>[
    averageCycleDays,
    averagePeriodDays,
    regularity,
    regularitySampleSize,
    prediction,
    totalTrackedCycles,
  ];
}
