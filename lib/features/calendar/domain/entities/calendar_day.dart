import 'package:equatable/equatable.dart';

import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';

/// One cell of the calendar grid. Computed by `buildCalendarDays` from the
/// raw cycle + day-log + prediction inputs.
class CalendarDay extends Equatable {
  const CalendarDay({
    required this.date,
    required this.isInDisplayedMonth,
    required this.isToday,
    required this.phase,
    this.flow,
    this.hasSymptoms = false,
    this.hasMood = false,
    this.hasOwnerNote = false,
    this.hasPartnerNote = false,
    this.isPredictedPeriod = false,
    this.isPredictedOvulation = false,
  });

  final DateTime date;
  final bool isInDisplayedMonth;
  final bool isToday;
  final CyclePhase phase;
  final FlowLevel? flow;
  final bool hasSymptoms;
  final bool hasMood;
  final bool hasOwnerNote;
  final bool hasPartnerNote;
  final bool isPredictedPeriod;
  final bool isPredictedOvulation;

  bool get hasAnyLog =>
      flow != null ||
      hasSymptoms ||
      hasMood ||
      hasOwnerNote ||
      hasPartnerNote;

  @override
  List<Object?> get props => [
        date,
        isInDisplayedMonth,
        isToday,
        phase,
        flow,
        hasSymptoms,
        hasMood,
        hasOwnerNote,
        hasPartnerNote,
        isPredictedPeriod,
        isPredictedOvulation,
      ];
}
