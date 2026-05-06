import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// Pill-shaped choice chip — used for filterable selections (mood, symptoms,
/// languages, etc.).
///
/// Visual model: unselected = pebble-toned pill on cream surface; selected =
/// solid terracotta pill with onPrimary text. No border by default — depth
/// comes from background tone contrast against the warm scaffold bg.
///
/// Pass [tint] to opt into a phase-specific color (e.g.
/// `BloomColors.phaseFollicular`) for the selected state — useful in the
/// logging sheet where chips are grouped by category.
///
/// Example:
/// ```dart
/// BloomChoiceChip(
///   label: 'Calm',
///   selected: state.mood == Mood.calm,
///   onTap: () => cubit.setMood(Mood.calm),
/// );
/// ```
class BloomChoiceChip extends StatelessWidget {
  const BloomChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tint,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = tint ?? theme.colorScheme.primary;
    final bg = selected ? accent : theme.colorScheme.surfaceContainer;
    final fg = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: BloomSpacing.s16,
          vertical: BloomSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BloomRadii.pillShape,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
