import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/utils/dates.dart';
import 'package:mycycle/features/calendar/domain/entities/calendar_day.dart';
import 'package:mycycle/features/calendar/domain/usecases/build_calendar_days.dart';
import 'package:mycycle/features/cycle/domain/predictions/prediction_engine.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';

sealed class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

final class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

final class CalendarLoaded extends CalendarState {
  const CalendarLoaded({
    required this.monthAnchor,
    required this.days,
  });

  final DateTime monthAnchor;
  final List<CalendarDay> days;

  @override
  List<Object?> get props => [monthAnchor, days];
}

final class CalendarError extends CalendarState {
  const CalendarError(this.error);
  final Object error;

  @override
  List<Object?> get props => [error];
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required this.coupleId,
    required CycleRepository cycleRepository,
    required DayLogRepository dayLogRepository,
    required CoupleRepository coupleRepository,
    required Clock clock,
  })  : _cycleRepo = cycleRepository,
        _dayLogRepo = dayLogRepository,
        _coupleRepo = coupleRepository,
        _clock = clock,
        super(const CalendarLoading()) {
    final today = _clock.now();
    _monthAnchor = DateTime.utc(today.year, today.month);
    _start();
  }

  final String coupleId;
  final CycleRepository _cycleRepo;
  final DayLogRepository _dayLogRepo;
  // Reserved for couple-default reads (cycle/luteal length) once the engine
  // accepts dynamic per-couple defaults instead of hardcoded 28/14.
  // ignore: unused_field
  final CoupleRepository _coupleRepo;
  final Clock _clock;

  late DateTime _monthAnchor;

  List<Cycle> _latestCycles = const [];
  Map<DateTime, DayLog> _latestLogs = const {};
  PredictionOutput? _latestPrediction;
  bool _hasCycles = false;
  bool _hasLogs = false;

  StreamSubscription<List<Cycle>>? _cyclesSub;
  StreamSubscription<List<DayLog>>? _logsSub;

  void _start() {
    _resubscribe();
  }

  void changeMonth(int direction) {
    final newAnchor = DateTime.utc(
      _monthAnchor.year,
      _monthAnchor.month + direction,
    );
    _monthAnchor = newAnchor;
    emit(const CalendarLoading());
    _resubscribe();
  }

  void jumpToToday() {
    final today = _clock.now();
    final targetAnchor = DateTime.utc(today.year, today.month);
    if (_monthAnchor == targetAnchor) return;
    _monthAnchor = targetAnchor;
    emit(const CalendarLoading());
    _resubscribe();
  }

  void _resubscribe() {
    unawaited(_cyclesSub?.cancel());
    unawaited(_logsSub?.cancel());
    _hasCycles = false;
    _hasLogs = false;

    final monthStart = _monthAnchor;
    final monthEnd = DateTime.utc(_monthAnchor.year, _monthAnchor.month + 1)
        .subtract(const Duration(days: 1));
    // 7-day buffer on each side so phase transitions across month boundaries
    // resolve correctly.
    final fromBuffered = monthStart.subtract(const Duration(days: 7));
    final toBuffered = monthEnd.add(const Duration(days: 7));

    _cyclesSub = _cycleRepo.watchRecentCycles(coupleId, limit: 24).listen(
      (cycles) {
        _latestCycles = cycles;
        _hasCycles = true;
        _latestPrediction = _computePrediction(cycles);
        _rebuild();
      },
      onError: (Object e) => emit(CalendarError(e)),
    );

    _logsSub =
        _dayLogRepo.watchRange(coupleId, fromBuffered, toBuffered).listen(
      (logs) {
        _latestLogs = <DateTime, DayLog>{
          for (final log in logs) normalizeDate(log.date): log,
        };
        _hasLogs = true;
        _rebuild();
      },
      onError: (Object e) => emit(CalendarError(e)),
    );
  }

  PredictionOutput? _computePrediction(List<Cycle> cycles) {
    final current = cycles.where((c) => c.isCurrent).firstOrNull;
    if (current == null) return null;
    final historical = cycles
        .where((c) => c.id != current.id && !c.isCurrent)
        .toList();
    return PredictionEngine.compute(
      PredictionInput(
        historicalCycles: historical,
        currentCycle: current,
        defaultCycleLength: 28,
        defaultLutealLength: 14,
        today: _clock.now(),
      ),
    );
  }

  void _rebuild() {
    if (isClosed) return;
    if (!_hasCycles || !_hasLogs) return;

    final days = buildCalendarDays(
      monthAnchor: _monthAnchor,
      cyclesIntersectingMonth: _latestCycles,
      dayLogsByDate: _latestLogs,
      prediction: _latestPrediction,
      today: _clock.now(),
    );

    emit(CalendarLoaded(monthAnchor: _monthAnchor, days: days));
  }

  @override
  Future<void> close() async {
    await _cyclesSub?.cancel();
    await _logsSub?.cancel();
    return super.close();
  }
}

extension on Iterable<Cycle> {
  Cycle? get firstOrNull {
    final iter = iterator;
    if (iter.moveNext()) return iter.current;
    return null;
  }
}
