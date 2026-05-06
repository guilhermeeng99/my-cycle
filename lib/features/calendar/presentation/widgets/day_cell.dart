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
      onTap: outOfMonth ? null : onTap,
      borderRadius: BorderRadius.circular(BloomRadii.lg),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (day.flow != null)
                _flowDisc(theme)
              else if (!outOfMonth)
                _phaseTint(phaseColor),
              if (day.isToday) _todayRing(theme),
              if (day.isPredictedPeriod && day.flow == null)
                _predictedRing(theme),
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
                  child: _dot(BloomColors.phaseOvulation, 5),
                )
              else if (day.hasAnyLog && day.flow == null && !outOfMonth)
                Positioned(bottom: 4, child: _dot(phaseColor, 4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flowDisc(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: _flowColor(day.flow!),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _phaseTint(Color phaseColor) {
    return Container(
      decoration: BoxDecoration(
        color: phaseColor.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _todayRing(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  Widget _predictedRing(ThemeData theme) {
    return CustomPaint(
      painter: _DashedCirclePainter(
        color: BloomColors.phaseMenstrual.withValues(alpha: 0.6),
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _dot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _textColor(ThemeData theme, bool outOfMonth) {
    if (outOfMonth) {
      return theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
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

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dashCount = 16;
    final radius = size.width / 2 - 0.6;
    final center = size.center(Offset.zero);
    const sweep = 6.2831853 / dashCount;
    for (var i = 0; i < dashCount; i++) {
      final start = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep * 0.55,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
