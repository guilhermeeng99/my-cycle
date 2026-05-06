import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class MonthHeader extends StatelessWidget {
  const MonthHeader({
    required this.monthAnchor,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.isOnTodayMonth,
    super.key,
  });

  final DateTime monthAnchor;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final bool isOnTodayMonth;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final locale = Localizations.localeOf(context).toString();
    final monthFmt = DateFormat.MMMM(locale);
    final yearFmt = DateFormat.y(locale);

    return BloomLargeHeader(
      title: _capitalize(monthFmt.format(monthAnchor)),
      subtitle: yearFmt.format(monthAnchor),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!isOnTodayMonth) ...<Widget>[
            _TodayPill(label: t.calendar.todayPill, onTap: onToday),
            const SizedBox(width: BloomSpacing.s8),
          ],
          _NavCircle(
            icon: BloomIcons.chevronLeft,
            tooltip: t.calendar.prevMonth,
            onTap: onPrev,
          ),
          const SizedBox(width: BloomSpacing.s8),
          _NavCircle(
            icon: BloomIcons.chevronRight,
            tooltip: t.calendar.nextMonth,
            onTap: onNext,
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _NavCircle extends StatelessWidget {
  const _NavCircle({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BloomSpacing.s12),
            child: Icon(
              icon,
              size: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayPill extends StatelessWidget {
  const _TodayPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BloomRadii.pillShape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.s16,
            vertical: BloomSpacing.s8,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final knownSunday = DateTime.utc(2024, 1, 7);
    final fmt = DateFormat.E(locale);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s12,
        vertical: BloomSpacing.s4,
      ),
      child: Row(
        children: List<Widget>.generate(7, (i) {
          final dayName = fmt.format(knownSunday.add(Duration(days: i)));
          return Expanded(
            child: Center(
              child: Text(
                dayName.substring(0, 1).toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
