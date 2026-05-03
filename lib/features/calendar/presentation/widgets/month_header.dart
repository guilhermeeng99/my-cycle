import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final monthFmt = DateFormat.yMMMM(locale);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s8,
        vertical: BloomSpacing.s8,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onPrev,
            icon: const Icon(BloomIcons.chevronLeft),
            tooltip: t.calendar.prevMonth,
          ),
          Expanded(
            child: Text(
              monthFmt.format(monthAnchor),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(BloomIcons.chevronRight),
            tooltip: t.calendar.nextMonth,
          ),
          if (!isOnTodayMonth)
            TextButton(
              onPressed: onToday,
              child: Text(t.calendar.todayPill),
            ),
        ],
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
    // A known Sunday — Jan 7 2024.
    final knownSunday = DateTime.utc(2024, 1, 7);
    final fmt = DateFormat.E(locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BloomSpacing.s4),
      child: Row(
        children: List<Widget>.generate(7, (i) {
          final dayName = fmt.format(knownSunday.add(Duration(days: i)));
          return Expanded(
            child: Center(
              child: Text(
                dayName.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
