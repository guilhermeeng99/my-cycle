import 'package:flutter_test/flutter_test.dart';

import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/features/calendar/domain/usecases/build_calendar_days.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';

import '../../../../harness/factories/cycle_factory.dart';

void main() {
  final today = DateTime.utc(2026, 5, 3);
  final monthAnchor = DateTime.utc(2026, 5);

  test('returns 42 cells for the displayed month grid', () {
    final days = buildCalendarDays(
      monthAnchor: monthAnchor,
      cyclesIntersectingMonth: const [],
      dayLogsByDate: const {},
      prediction: null,
      today: today,
    );
    expect(days, hasLength(42));
  });

  test('grid begins on the Sunday containing the 1st of the month', () {
    final days = buildCalendarDays(
      monthAnchor: monthAnchor,
      cyclesIntersectingMonth: const [],
      dayLogsByDate: const {},
      prediction: null,
      today: today,
    );
    // May 1, 2026 is a Friday → grid starts April 26 (Sunday).
    expect(days.first.date, DateTime.utc(2026, 4, 26));
    // Last cell is 41 days later.
    expect(days.last.date, DateTime.utc(2026, 6, 6));
  });

  test('flags isToday on exactly the matching cell', () {
    final days = buildCalendarDays(
      monthAnchor: monthAnchor,
      cyclesIntersectingMonth: const [],
      dayLogsByDate: const {},
      prediction: null,
      today: today,
    );
    final todayCells = days.where((d) => d.isToday).toList();
    expect(todayCells, hasLength(1));
    expect(todayCells.single.date, today);
  });

  test('overflow days are flagged !isInDisplayedMonth', () {
    final days = buildCalendarDays(
      monthAnchor: monthAnchor,
      cyclesIntersectingMonth: const [],
      dayLogsByDate: const {},
      prediction: null,
      today: today,
    );
    expect(days.first.isInDisplayedMonth, isFalse); // April 26
    final mid = days.firstWhere((d) => d.date.day == 15);
    expect(mid.isInDisplayedMonth, isTrue);
    expect(days.last.isInDisplayedMonth, isFalse); // June 6
  });

  test('cycle phase resolves to menstrual on cycle start days', () {
    final cycle = CycleFactory.firstEver(startDate: DateTime.utc(2026, 5));
    final days = buildCalendarDays(
      monthAnchor: monthAnchor,
      cyclesIntersectingMonth: <dynamic>[cycle].cast(),
      dayLogsByDate: const {},
      prediction: null,
      today: today,
    );
    final start = days.firstWhere((d) => d.date == DateTime.utc(2026, 5));
    expect(start.phase, CyclePhase.menstrual);
  });

  test('flow on the day log is reflected in the cell', () {
    final cycle = CycleFactory.firstEver(startDate: DateTime.utc(2026, 5));
    final logDate = DateTime.utc(2026, 5, 2);
    final days = buildCalendarDays(
      monthAnchor: monthAnchor,
      cyclesIntersectingMonth: <dynamic>[cycle].cast(),
      dayLogsByDate: <DateTime, DayLog>{
        logDate: DayLog(
          coupleId: 'couple-1',
          date: logDate,
          flow: FlowLevel.medium,
          createdAt: today,
          updatedAt: today,
        ),
      },
      prediction: null,
      today: today,
    );
    final cell = days.firstWhere((d) => d.date == logDate);
    expect(cell.flow, FlowLevel.medium);
    expect(cell.hasAnyLog, isTrue);
  });
}
