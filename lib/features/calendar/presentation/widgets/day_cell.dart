import 'package:flutter/material.dart';

import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/calendar/domain/entities/calendar_day.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';

class DayCell extends StatelessWidget {
  const DayCell({required this.day, required this.onTap, super.key});

  final CalendarDay day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outOfMonth = !day.isInDisplayedMonth;
    final phaseColor = _phaseColor(day.phase);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BloomRadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: _decoration(theme, phaseColor),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (day.flow != null)
                  Container(
                    decoration: BoxDecoration(
                      color: _flowColor(day.flow!),
                      shape: BoxShape.circle,
                    ),
                    width: 32,
                    height: 32,
                  ),
                Text(
                  '${day.date.day}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _textColor(theme, outOfMonth),
                    fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (day.isPredictedOvulation)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: BloomColors.phaseOvulation,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                else if (day.hasAnyLog && day.flow == null)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: phaseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration(ThemeData theme, Color phaseColor) {
    final isPredictedPeriod = day.isPredictedPeriod;
    final isToday = day.isToday;
    final outOfMonth = !day.isInDisplayedMonth;
    final fillOpacity = outOfMonth ? 0.0 : 0.10;

    Border? border;
    if (isToday) {
      border = Border.all(color: BloomColors.rose, width: 1.5);
    } else if (isPredictedPeriod) {
      border = Border.all(
        color: BloomColors.rose.withValues(alpha: 0.6),
      );
    }

    return BoxDecoration(
      color: phaseColor.withValues(alpha: fillOpacity),
      shape: BoxShape.circle,
      border: border,
    );
  }

  Color _textColor(ThemeData theme, bool outOfMonth) {
    if (outOfMonth) {
      return theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    }
    if (day.flow != null) return theme.colorScheme.onPrimary;
    return theme.colorScheme.onSurface;
  }

  Color _phaseColor(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstrual => BloomColors.phaseMenstrual,
      CyclePhase.follicular => BloomColors.phaseFollicular,
      CyclePhase.ovulation => BloomColors.phaseOvulation,
      CyclePhase.luteal => BloomColors.phaseLuteal,
      CyclePhase.unknown => BloomColors.whisperGray,
    };
  }

  Color _flowColor(FlowLevel level) {
    return switch (level) {
      FlowLevel.spotting =>
        BloomColors.phaseMenstrual.withValues(alpha: 0.55),
      FlowLevel.light => BloomColors.phaseMenstrual.withValues(alpha: 0.75),
      FlowLevel.medium => BloomColors.phaseMenstrual,
      FlowLevel.heavy => BloomColors.roseDeep,
    };
  }
}
