import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/errors/result.dart';

abstract class CycleRepository {
  /// The currently-open cycle for [coupleId] (one whose `totalLengthDays` is
  /// null). Emits `null` if no cycle exists yet.
  Stream<Cycle?> watchCurrentCycle(String coupleId);

  /// Recent cycles (closed and current), most-recent first. Used by the
  /// prediction engine and the calendar.
  Stream<List<Cycle>> watchRecentCycles(
    String coupleId, {
    int limit = 12,
  });

  /// Starts a new cycle for [coupleId] on [startDate]. If a current cycle
  /// already exists, closes it first by setting its `totalLengthDays` to
  /// `daysBetween(oldStart, startDate)` (per `cycle.md` BR-3).
  ///
  /// Returns the freshly-created [Cycle] on success.
  Future<Result<Cycle>> startNewCycle({
    required String coupleId,
    required DateTime startDate,
  });

  /// Sets `periodEndDate` on the cycle identified by ([coupleId], [cycleId]).
  Future<Result<Cycle>> setPeriodEnd({
    required String coupleId,
    required String cycleId,
    required DateTime endDate,
  });
}
