import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/utils/dates.dart';
import 'package:mycycle/features/cycle/domain/predictions/prediction_engine.dart';

/// Phase of the menstrual cycle on a given day.
enum CyclePhase { menstrual, follicular, ovulation, luteal, unknown }

/// Pure function — given a cycle, today's date, and an optional prediction,
/// returns the [CyclePhase] for [today].
///
/// Without a prediction we can only identify the menstrual phase from
/// `[startDate, periodEndDate ?? startDate + 5d]`. Other phases collapse to
/// `unknown` until we can compute a fertile window.
CyclePhase computeCyclePhase({
  required Cycle currentCycle,
  required DateTime today,
  PredictionOutput? prediction,
}) {
  final start = normalizeDate(currentCycle.startDate);
  final t = normalizeDate(today);

  final periodEnd = currentCycle.periodEndDate != null
      ? normalizeDate(currentCycle.periodEndDate!)
      : start.add(const Duration(days: 4)); // assumed 5-day period

  if (!t.isBefore(start) && !t.isAfter(periodEnd)) {
    return CyclePhase.menstrual;
  }

  if (prediction == null) return CyclePhase.unknown;

  final fertileStart = normalizeDate(prediction.fertileWindowStart);
  final fertileEnd = normalizeDate(prediction.fertileWindowEnd);
  final nextStart = normalizeDate(prediction.predictedNextStart);

  if (t.isBefore(fertileStart)) return CyclePhase.follicular;
  if (!t.isAfter(fertileEnd)) return CyclePhase.ovulation;
  if (t.isBefore(nextStart)) return CyclePhase.luteal;

  return CyclePhase.unknown;
}

/// Day-of-cycle (1-indexed) for [today] within [cycle].
int computeDayOfCycle(Cycle cycle, DateTime today) {
  return daysBetween(cycle.startDate, today) + 1;
}
