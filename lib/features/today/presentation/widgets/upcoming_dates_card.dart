import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

/// Predicted dates summary for the Today screen.
///
/// FocusPomo-tuned: lives inside a [BloomSectionCard] titled "Upcoming";
/// each row uses a phase-color leading dot, a label, a date range, and an
/// optional confidence pill for the period prediction. Replaces the
/// previous gradient + raw container layout.
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
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.MMMd(locale);
    final t = context.t;

    return BloomSectionCard(
      title: t.today.upcomingTitle,
      children: <Widget>[
        _Row(
          dot: BloomColors.phaseMenstrual,
          label: t.today.nextPeriodTitle,
          value: t.today.aroundRange(
            from: fmt.format(nextStart),
            to: fmt.format(nextEnd),
          ),
          trailing: _ConfidencePill(level: confidence),
        ),
        const SizedBox(height: BloomSpacing.s16),
        _Row(
          dot: BloomColors.phaseOvulation,
          label: t.today.fertileWindowTitle,
          value: t.today.aroundRange(
            from: fmt.format(fertileStart),
            to: fmt.format(fertileEnd),
          ),
          subtitle: t.today.ovulationOn(date: fmt.format(ovulation)),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.dot,
    required this.label,
    required this.value,
    this.subtitle,
    this.trailing,
  });

  final Color dot;
  final String label;
  final String value;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: dot.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: BloomSpacing.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
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
        ?trailing,
      ],
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
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BloomRadii.pillShape,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
