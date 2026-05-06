import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// Colored block in a vertical timeline — the FocusPomo "English / Focus /
/// Fitness" pattern.
///
/// Renders a label on the left and a trailing string (typically a duration
/// like "25m" or a status like "Late 1d") on the right, both in onPrimary
/// over the [tone] background. The block height grows with the [stretch]
/// factor (1.0 = baseline; FocusPomo's 1h block is roughly 2× the 25m one).
///
/// Pass a phase color from `BloomColors.phaseMenstrual` etc. for cycle-day
/// blocks; pass any neutral surface color for non-phase categories.
///
/// Example:
/// ```dart
/// BloomTimelineBlock(
///   label: 'Period',
///   trailing: 'Day 3',
///   tone: BloomColors.phaseMenstrual,
/// );
/// ```
class BloomTimelineBlock extends StatelessWidget {
  const BloomTimelineBlock({
    required this.label,
    required this.tone,
    this.trailing,
    this.stretch = 1.0,
    this.muted = false,
    super.key,
  });

  final String label;
  final Color tone;
  final String? trailing;
  final double stretch;

  /// When true, fades the block (FocusPomo "Fitness" upcoming-block look).
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = muted ? tone.withValues(alpha: 0.5) : tone;
    final fg = theme.colorScheme.onPrimary;
    return Container(
      constraints: BoxConstraints(minHeight: 56 * stretch),
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s16,
        vertical: BloomSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BloomRadii.blockShape,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
