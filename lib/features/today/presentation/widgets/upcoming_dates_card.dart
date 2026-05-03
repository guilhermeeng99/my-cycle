import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class UpcomingDatesCard extends StatelessWidget {
  const UpcomingDatesCard({
    required this.nextStart,
    required this.nextEnd,
    required this.confidence,
    required this.fertileStart,
    required this.fertileEnd,
    required this.ovulation,
    super.key,
  });

  final DateTime nextStart;
  final DateTime nextEnd;
  final ConfidenceLevel confidence;
  final DateTime fertileStart;
  final DateTime fertileEnd;
  final DateTime ovulation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.MMMd(locale);
    final t = context.t;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Row(
            dot: BloomColors.phaseMenstrual,
            label: t.today.nextPeriodTitle,
            value: t.today.aroundRange(
              from: fmt.format(nextStart),
              to: fmt.format(nextEnd),
            ),
            valueColor: BloomColors.phaseMenstrual,
            trailing: _ConfidencePill(level: confidence),
            isPrimary: true,
          ),
          _Hairline(color: theme.colorScheme.outline),
          _Row(
            dot: BloomColors.phaseOvulation,
            label: t.today.fertileWindowTitle,
            value: t.today.aroundRange(
              from: fmt.format(fertileStart),
              to: fmt.format(fertileEnd),
            ),
            valueColor: theme.colorScheme.onSurface,
            subtitle: t.today.ovulationOn(date: fmt.format(ovulation)),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.dot,
    required this.label,
    required this.value,
    required this.valueColor,
    this.subtitle,
    this.trailing,
    this.isPrimary = false,
  });

  final Color dot;
  final String label;
  final String value;
  final Color valueColor;
  final String? subtitle;
  final Widget? trailing;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(BloomSpacing.s20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: BloomSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: BloomSpacing.s4),
                Text(
                  value,
                  style: (isPrimary
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.titleMedium)
                      ?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: BloomSpacing.s4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BloomSpacing.s20),
      child: Container(height: 0.5, color: color.withValues(alpha: 0.4)),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  const _ConfidencePill({required this.level});
  final ConfidenceLevel level;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final (label, color) = switch (level) {
      ConfidenceLevel.low => (t.today.confidenceLow, BloomColors.whisperGray),
      ConfidenceLevel.medium => (t.today.confidenceMedium, BloomColors.honey),
      ConfidenceLevel.high => (t.today.confidenceHigh, BloomColors.sage),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s12,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BloomRadii.pillShape,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
