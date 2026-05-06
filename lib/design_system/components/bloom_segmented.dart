import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// One option in a [BloomSegmented] control.
class BloomSegment<T> {
  const BloomSegment({required this.value, required this.label});
  final T value;
  final String label;
}

/// Pill-shaped segmented control — FocusPomo-style.
///
/// The track is a soft pebble pill; the selected segment is a terracotta
/// pill thumb with onPrimary text. Switching between segments animates the
/// background fill in 200ms.
///
/// Example:
/// ```dart
/// BloomSegmented<AppLanguage>(
///   value: lang,
///   segments: const [
///     BloomSegment(value: AppLanguage.en, label: 'EN'),
///     BloomSegment(value: AppLanguage.ptBr, label: 'PT-BR'),
///   ],
///   onChanged: (v) => cubit.updateLanguage(v),
/// )
/// ```
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BloomRadii.pillShape,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments
            .map(
              (s) => _Segment<T>(
                segment: s,
                selected: s.value == value,
                onTap: () => onChanged(s.value),
              ),
            )
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
          horizontal: BloomSpacing.s16,
          vertical: BloomSpacing.s8,
        ),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BloomRadii.pillShape,
        ),
        child: Text(
          segment.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
