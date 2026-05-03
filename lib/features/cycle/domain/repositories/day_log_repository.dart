import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/errors/result.dart';

abstract class DayLogRepository {
  /// Watch one day's log. Emits `null` when no document exists for [date].
  Stream<DayLog?> watchDay(String coupleId, DateTime date);

  /// Watch a date range, inclusive on both ends. Useful for the calendar and
  /// the recent-days strip on Today.
  Stream<List<DayLog>> watchRange(
    String coupleId,
    DateTime from,
    DateTime to,
  );

  /// Write [log] to Firestore (overwrites any existing entry for the date).
  Future<Result<DayLog>> upsertDayLog(DayLog log);

  /// Delete the day log for [date]. No-op if it doesn't exist.
  Future<Result<void>> deleteDayLog(String coupleId, DateTime date);
}
