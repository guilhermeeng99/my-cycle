import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class PhaseNarrativeCard extends StatelessWidget {
  const PhaseNarrativeCard({required this.phase, super.key});

  final CyclePhase phase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;
    final tint = _phaseColor(phase);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s20,
        vertical: BloomSpacing.s16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            tint.withValues(alpha: 0.10),
            tint.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BloomRadii.card,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 6,
            height: 36,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(BloomRadii.pill),
            ),
          ),
          const SizedBox(width: BloomSpacing.s16),
          Expanded(
            child: Text(
              _phaseCopy(phase, t),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
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
