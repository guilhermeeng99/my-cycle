import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/logging/domain/failures/log_failure.dart';

class SaveDayLogParams {
  const SaveDayLogParams({
    required this.coupleId,
    required this.date,
    required this.flow,
    required this.symptoms,
    required this.mood,
    required this.ownerNote,
    required this.markPeriodStarted,
    required this.markPeriodEnded,
    this.currentCycleId,
  });

  final String coupleId;
  final String? currentCycleId;
  final DateTime date;
  final FlowLevel? flow;
  final Set<SymptomType> symptoms;
  final MoodType? mood;
  final String? ownerNote;
  final bool markPeriodStarted;
  final bool markPeriodEnded;

  bool get hasAnyDayData =>
      flow != null ||
      symptoms.isNotEmpty ||
      mood != null ||
      (ownerNote != null && ownerNote!.trim().isNotEmpty);
}

/// Orchestrates the bottom-sheet save flow:
/// 1. Optionally start a new cycle (closing the previous one).
/// 2. Optionally mark period end on the current cycle.
/// 3. Upsert / delete the day log per its emptiness.
class SaveDayLog {
  const SaveDayLog({
    required this.cycleRepository,
    required this.dayLogRepository,
    required this.clock,
  });

  final CycleRepository cycleRepository;
  final DayLogRepository dayLogRepository;
  final Clock clock;

  Future<Result<void>> call(SaveDayLogParams params) async {
    if ((params.ownerNote?.length ?? 0) > 500) {
      return const Err<void>(
        LogValidationFailure('ownerNote', 'Note exceeds 500 characters'),
      );
    }

    // 1. Period started → start new cycle (closes the previous one if any).
    if (params.markPeriodStarted) {
      final r = await cycleRepository.startNewCycle(
        coupleId: params.coupleId,
        startDate: params.date,
      );
      if (r case Err(:final error)) return Err<void>(error);
    }

    // 2. Period ended → set on current cycle (must have a current cycle).
    if (params.markPeriodEnded && params.currentCycleId != null) {
      final r = await cycleRepository.setPeriodEnd(
        coupleId: params.coupleId,
        cycleId: params.currentCycleId!,
        endDate: params.date,
      );
      if (r case Err(:final error)) return Err<void>(error);
    }

    // 3. Day log: delete if empty, otherwise upsert.
    if (!params.hasAnyDayData) {
      return dayLogRepository.deleteDayLog(params.coupleId, params.date);
    }

    final now = clock.now();
    final log = DayLog(
      coupleId: params.coupleId,
      date: params.date,
      flow: params.flow,
      symptoms: params.symptoms,
      mood: params.mood,
      ownerNote: (params.ownerNote == null || params.ownerNote!.trim().isEmpty)
          ? null
          : params.ownerNote!.trim(),
      createdAt: now,
      updatedAt: now,
    );
    final r = await dayLogRepository.upsertDayLog(log);
    return switch (r) {
      Ok<DayLog>() => const Ok<void>(null),
      Err<DayLog>(:final error) => Err<void>(error),
    };
  }
}
