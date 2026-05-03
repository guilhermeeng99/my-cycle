import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

class BloomSegment<T> {
  const BloomSegment({required this.value, required this.label});
  final T value;
  final String label;
}

class BloomSegmented<T> extends StatelessWidget {
  const BloomSegmented({
    required this.segments,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<BloomSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(BloomRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments
            .map((s) => _Segment<T>(
                  segment: s,
                  selected: s.value == value,
                  onTap: () => onChanged(s.value),
                ))
            .toList(),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final BloomSegment<T> segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: BloomSpacing.s12,
          vertical: BloomSpacing.s4,
        ),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(BloomRadii.sm),
        ),
        child: Text(
          segment.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
