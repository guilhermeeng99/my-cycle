import 'package:flutter/material.dart';

import 'package:mycycle/design_system/tokens/tokens.dart';

/// Single day in a [BloomDayPillRow].
class BloomDayPill {
  const BloomDayPill({
    required this.date,
    required this.dayLabel,
    required this.numberLabel,
  });

  /// The actual date represented by the pill — used as the selection value
  /// (compared with `==`) and passed back to the `onSelected` callback.
  final DateTime date;

  /// Short weekday label rendered above the number (e.g. "Mon", "Tue").
  /// Pass already-localized + abbreviated text — the component only renders.
  final String dayLabel;

  /// Day-of-month number (e.g. "12", "13"). Same locale-already-applied
  /// contract as [dayLabel].
  final String numberLabel;
}

/// Horizontal row of weekday pills — the FocusPomo "Mon 12 / Tue 13 / ..."
/// strip at the top of the timeline screen.
///
/// The pill matching [selected] (by `date == selected`) renders in the
/// terracotta accent with onPrimary text; all others render on the
/// `surfaceContainer` pebble tone with onSurface text.
///
/// Tap targets are 56×56pt — meets accessibility minimum and matches the
/// FocusPomo screenshot's chunky, thumb-friendly feel.
///
/// Example:
/// ```dart
/// BloomDayPillRow(
///   pills: weekPills,
///   selected: selectedDate,
///   onSelected: cubit.selectDate,
/// );
/// ```
class BloomDayPillRow extends StatelessWidget {
  const BloomDayPillRow({
    required this.pills,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<BloomDayPill> pills;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: pills
          .map(
            (p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BloomSpacing.s4,
                ),
                child: _Pill(
                  pill: p,
                  selected: _sameDay(p.date, selected),
                  onTap: () => onSelected(p.date),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.pill,
    required this.selected,
    required this.onTap,
  });

  final BloomDayPill pill;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainer;
    final dayColor = selected
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.85)
        : theme.colorScheme.onSurfaceVariant;
    final numColor = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          vertical: BloomSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(BloomRadii.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              pill.dayLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: dayColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pill.numberLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: numColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
