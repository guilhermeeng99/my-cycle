import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/utils/dates.dart';
import 'package:mycycle/features/calendar/domain/entities/calendar_day.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';
import 'package:mycycle/features/cycle/domain/predictions/prediction_engine.dart';

/// Pure function — given the input data for a month, returns 42 cells (6 × 7
/// grid) starting on the Sunday that contains the first day of [monthAnchor]'s
/// month.
///
/// Days outside the displayed month (overflow rows) are flagged via
/// `isInDisplayedMonth = false` so the UI can render them at lower opacity.
List<CalendarDay> buildCalendarDays({
  required DateTime monthAnchor,
  required List<Cycle> cyclesIntersectingMonth,
  required Map<DateTime, DayLog> dayLogsByDate,
  required PredictionOutput? prediction,
  required DateTime today,
}) {
  final firstOfMonth = DateTime.utc(monthAnchor.year, monthAnchor.month);
  final gridStart = _gridStartForMonth(firstOfMonth);
  final normalizedToday = normalizeDate(today);
  final normalizedLogs = <DateTime, DayLog>{
    for (final entry in dayLogsByDate.entries)
      normalizeDate(entry.key): entry.value,
  };

  return List<CalendarDay>.generate(42, (i) {
    final date = gridStart.add(Duration(days: i));
    final isInDisplayedMonth = date.month == firstOfMonth.month;
    final isToday = _isSameDay(date, normalizedToday);

    final cycle = _findCycleContaining(date, cyclesIntersectingMonth);
    final phase = cycle == null
        ? CyclePhase.unknown
        : computeCyclePhase(
            currentCycle: cycle,
            today: date,
            prediction: cycle.isCurrent ? prediction : null,
          );

    final log = normalizedLogs[date];
    final isPredictedPeriod = prediction != null &&
        !date.isBefore(normalizeDate(prediction.predictedNextStart)) &&
        !date.isAfter(normalizeDate(prediction.predictedNextStartRangeEnd));
    final isPredictedOvulation = prediction != null &&
        _isSameDay(date, prediction.predictedOvulation);

    return CalendarDay(
      date: date,
      isInDisplayedMonth: isInDisplayedMonth,
      isToday: isToday,
      phase: phase,
      flow: log?.flow,
      hasSymptoms: log?.symptoms.isNotEmpty ?? false,
      hasMood: log?.mood != null,
      hasOwnerNote: log?.ownerNote?.isNotEmpty ?? false,
      hasPartnerNote: log?.partnerNote?.isNotEmpty ?? false,
      isPredictedPeriod: isPredictedPeriod,
      isPredictedOvulation: isPredictedOvulation,
    );
  });
}

/// Sunday that begins the row containing the 1st of [firstOfMonth].
DateTime _gridStartForMonth(DateTime firstOfMonth) {
  final weekday = firstOfMonth.weekday; // Mon=1..Sun=7
  // Map Sunday(7) to 0 so we shift back the right number of days.
  final daysBack = weekday % 7;
  return firstOfMonth.subtract(Duration(days: daysBack));
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Cycle? _findCycleContaining(DateTime date, List<Cycle> cycles) {
  // [Cycle] list is most-recent-first. The cycle that contains `date` is the
  // one whose `startDate <= date < nextCycle.startDate`. Iterate ordered.
  Cycle? bestMatch;
  for (final cycle in cycles) {
    final start = normalizeDate(cycle.startDate);
    if (date.isBefore(start)) continue;
    if (bestMatch == null) {
      bestMatch = cycle;
      continue;
    }
    // Pick the cycle with the latest start date that is still ≤ date.
    if (start.isAfter(normalizeDate(bestMatch.startDate))) {
      bestMatch = cycle;
    }
  }
  return bestMatch;
}
