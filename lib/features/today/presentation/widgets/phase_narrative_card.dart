import 'package:flutter/material.dart';

import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// Compact phase narrative — a short "what's happening" copy paired with a
/// phase-color tag. Sits inside the Today screen below the cycle ring.
///
/// FocusPomo-tuned: lives inside a [BloomSectionCard] with a small phase
/// pill on the leading edge instead of a vertical color bar + gradient.
class PhaseNarrativeCard extends StatelessWidget {
  const PhaseNarrativeCard({required this.phase, super.key});

  final CyclePhase phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final tint = _phaseColor(phase);
    final copy = _phaseCopy(phase, t);
    if (copy.isEmpty) return const SizedBox.shrink();

    return BloomSectionCard(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _PhasePill(label: _phaseLabel(phase, t), tint: tint),
            const SizedBox(width: BloomSpacing.s12),
            Expanded(
              child: Text(
                copy,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ],
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
    };
  }

  static String _phaseCopy(CyclePhase phase, Translations t) {
    return switch (phase) {
      CyclePhase.menstrual => t.today.phaseCopyMenstrual,
      CyclePhase.follicular => t.today.phaseCopyFollicular,
      CyclePhase.ovulation => t.today.phaseCopyOvulation,
      CyclePhase.luteal => t.today.phaseCopyLuteal,
      CyclePhase.unknown => '',
    };
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BloomRadii.pillShape,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: tint,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
