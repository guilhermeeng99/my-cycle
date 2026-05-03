import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

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
    final bg = selected
        ? accent.withValues(alpha: 0.16)
        : theme.colorScheme.surface;
    final fg =
        selected ? accent : theme.colorScheme.onSurface.withValues(alpha: 0.8);

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
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.4)
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: fg,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
