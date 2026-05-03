import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';

/// Hero ring on the Today screen. Shows the current day-of-cycle as a partial
/// arc, colored by the active [CyclePhase]. Lightweight v1 — no animation,
/// no phase-quadrant rendering yet.
class CycleRing extends StatelessWidget {
  const CycleRing({
    required this.dayN,
    required this.cycleLengthEstimate,
    required this.phase,
    super.key,
    this.size = 220,
    this.strokeWidth = 16,
  });

  final int dayN;
  final int cycleLengthEstimate;
  final CyclePhase phase;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (dayN / cycleLengthEstimate).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          phaseColor: _phaseColor(phase),
          trackColor: theme.colorScheme.outline,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _phaseLabel(phase, context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: BloomSpacing.s4),
              Text(
                '$dayN',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1,
                ),
              ),
              const SizedBox(height: BloomSpacing.s4),
              Text(
                'day $dayN of ~$cycleLengthEstimate',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _phaseColor(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstrual => BloomColors.phaseMenstrual,
      CyclePhase.follicular => BloomColors.phaseFollicular,
      CyclePhase.ovulation => BloomColors.phaseOvulation,
      CyclePhase.luteal => BloomColors.phaseLuteal,
      CyclePhase.unknown => BloomColors.whisperGray,
    };
  }

  static String _phaseLabel(CyclePhase phase, BuildContext context) {
    return switch (phase) {
      CyclePhase.menstrual => 'menstrual',
      CyclePhase.follicular => 'follicular',
      CyclePhase.ovulation => 'ovulation',
      CyclePhase.luteal => 'luteal',
      CyclePhase.unknown => '—',
    }
        .toUpperCase();
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.phaseColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color phaseColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = phaseColor;

    canvas
      ..drawCircle(center, radius, track)
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) {
    return old.progress != progress ||
        old.phaseColor != phaseColor ||
        old.trackColor != trackColor ||
        old.strokeWidth != strokeWidth;
  }
}
