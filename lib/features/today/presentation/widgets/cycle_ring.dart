import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class CycleRing extends StatefulWidget {
  const CycleRing({
    required this.dayN,
    required this.cycleLengthEstimate,
    required this.phase,
    super.key,
    this.size = 240,
    this.strokeWidth = 14,
  });

  final int dayN;
  final int cycleLengthEstimate;
  final CyclePhase phase;
  final double size;
  final double strokeWidth;

  @override
  State<CycleRing> createState() => _CycleRingState();
}

class _CycleRingState extends State<CycleRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    unawaited(_pulse.repeat(reverse: true));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final progress =
        (widget.dayN / widget.cycleLengthEstimate).clamp(0.0, 1.0);
    final phaseColor = _phaseColor(widget.phase);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, _) {
          final t01 = Curves.easeInOut.transform(_pulse.value);
          final scale = 0.985 + 0.015 * t01;
          return Transform.scale(
            scale: scale,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                phaseColor: phaseColor,
                trackColor:
                    theme.colorScheme.outline.withValues(alpha: 0.35),
                strokeWidth: widget.strokeWidth,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BloomSpacing.s24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _phaseLabel(widget.phase, t),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: phaseColor,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: BloomSpacing.s4),
                      Text(
                        '${widget.dayN}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: BloomSpacing.s4),
                      Text(
                        t.today.dayOfCycle(
                          n: widget.dayN.toString(),
                          total: widget.cycleLengthEstimate.toString(),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

  static String _phaseLabel(CyclePhase phase, Translations t) {
    return switch (phase) {
      CyclePhase.menstrual => t.today.phaseMenstrual,
      CyclePhase.follicular => t.today.phaseFollicular,
      CyclePhase.ovulation => t.today.phaseOvulation,
      CyclePhase.luteal => t.today.phaseLuteal,
      CyclePhase.unknown => t.today.phaseUnknown,
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
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
        colors: <Color>[
          phaseColor.withValues(alpha: 0.55),
          phaseColor,
        ],
      ).createShader(rect);

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
