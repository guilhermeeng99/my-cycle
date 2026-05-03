import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';
import 'package:mycycle/features/cycle/domain/predictions/prediction_engine.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';

class TodayViewModel extends Equatable {
  const TodayViewModel({
    required this.user,
    required this.couple,
    required this.currentCycle,
    required this.dayN,
    required this.phase,
    required this.prediction,
    required this.isLatePeriod,
    required this.latenessDays,
  });

  final User user;
  final Couple couple;
  final Cycle currentCycle;
  final int dayN;
  final CyclePhase phase;
  final PredictionOutput prediction;
  final bool isLatePeriod;
  final int latenessDays;

  /// Estimated cycle length used for the ring's full circle. Computed as the
  /// midpoint of the predicted-next-period range.
  int get cycleLengthEstimate {
    final start = currentCycle.startDate;
    final rangeWidthDays = prediction.predictedNextStartRangeEnd
        .difference(prediction.predictedNextStart)
        .inDays;
    final midpoint = prediction.predictedNextStart.add(
      Duration(days: rangeWidthDays ~/ 2),
    );
    return midpoint.difference(start).inDays.clamp(21, 60);
  }

  @override
  List<Object?> get props => [
        user,
        couple,
        currentCycle,
        dayN,
        phase,
        prediction,
        isLatePeriod,
        latenessDays,
      ];
}

sealed class TodayState extends Equatable {
  const TodayState();

  @override
  List<Object?> get props => [];
}

final class TodayLoading extends TodayState {
  const TodayLoading();
}

final class TodayLoaded extends TodayState {
  const TodayLoaded(this.vm);
  final TodayViewModel vm;

  @override
  List<Object?> get props => [vm];
}

final class TodayEmpty extends TodayState {
  const TodayEmpty();
}

final class TodayError extends TodayState {
  const TodayError(this.error);
  final Object error;

  @override
  List<Object?> get props => [error];
}

class TodayCubit extends Cubit<TodayState> {
  TodayCubit({
    required User user,
    required CycleRepository cycleRepository,
    required CoupleRepository coupleRepository,
    required Clock clock,
  })  : _user = user,
        _cycleRepo = cycleRepository,
        _coupleRepo = coupleRepository,
        _clock = clock,
        super(const TodayLoading()) {
    final coupleId = user.coupleId;
    if (coupleId == null) {
      emit(const TodayEmpty());
      return;
    }
    _start(coupleId);
  }

  final User _user;
  final CycleRepository _cycleRepo;
  final CoupleRepository _coupleRepo;
  final Clock _clock;

  Couple? _latestCouple;
  Cycle? _latestCurrentCycle;
  List<Cycle> _latestRecentCycles = const [];

  StreamSubscription<Couple?>? _coupleSub;
  StreamSubscription<Cycle?>? _currentCycleSub;
  StreamSubscription<List<Cycle>>? _recentCyclesSub;

  void _start(String coupleId) {
    _coupleSub = _coupleRepo.watchCouple(coupleId).listen(
          (couple) {
            _latestCouple = couple;
            _rebuild();
          },
          onError: (Object e) => emit(TodayError(e)),
        );
    _currentCycleSub = _cycleRepo.watchCurrentCycle(coupleId).listen(
          (cycle) {
            _latestCurrentCycle = cycle;
            _rebuild();
          },
          onError: (Object e) => emit(TodayError(e)),
        );
    _recentCyclesSub = _cycleRepo.watchRecentCycles(coupleId).listen(
          (cycles) {
            _latestRecentCycles = cycles;
            _rebuild();
          },
          onError: (Object e) => emit(TodayError(e)),
        );
  }

  void _rebuild() {
    if (isClosed) return;
    final couple = _latestCouple;
    final cycle = _latestCurrentCycle;

    // Couple is required; current cycle is required to render Today.
    if (couple == null) return;
    if (cycle == null) {
      emit(const TodayEmpty());
      return;
    }

    final today = _clock.now();
    final historical = _latestRecentCycles
        .where((c) => c.id != cycle.id && c.totalLengthDays != null)
        .toList();

    final prediction = PredictionEngine.compute(
      PredictionInput(
        historicalCycles: historical,
        currentCycle: cycle,
        defaultCycleLength: couple.defaultCycleLength,
        defaultLutealLength: couple.defaultLutealLength,
        today: today,
      ),
    );

    final phase = computeCyclePhase(
      currentCycle: cycle,
      today: today,
      prediction: prediction,
    );
    final dayN = computeDayOfCycle(cycle, today);

    final daysFromMidpoint =
        today.difference(prediction.predictedNextStart).inDays;
    final isLate = daysFromMidpoint >= 3;

    emit(
      TodayLoaded(
        TodayViewModel(
          user: _user,
          couple: couple,
          currentCycle: cycle,
          dayN: dayN,
          phase: phase,
          prediction: prediction,
          isLatePeriod: isLate,
          latenessDays: isLate ? daysFromMidpoint : 0,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _coupleSub?.cancel();
    await _currentCycleSub?.cancel();
    await _recentCyclesSub?.cancel();
    return super.close();
  }
}
