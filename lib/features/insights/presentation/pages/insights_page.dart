import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/predictions/prediction_engine.dart';
import 'package:mycycle/features/insights/presentation/cubits/insights_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(title: Text(t.insights.title)),
      body: SafeArea(
        child: BlocBuilder<InsightsCubit, InsightsState>(
          builder: (context, state) => switch (state) {
            InsightsLoading() =>
              const Center(child: CircularProgressIndicator()),
            InsightsEmpty() => const _EmptyState(),
            InsightsLoaded() => _LoadedBody(state: state),
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(BloomSpacing.screenEdge),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              t.insights.emptyTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BloomSpacing.s12),
            Text(
              t.insights.emptyBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});
  final InsightsLoaded state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(BloomSpacing.screenEdge),
      children: <Widget>[
        if (state.prediction != null) ...<Widget>[
          _NextPredictionCard(prediction: state.prediction!),
          const SizedBox(height: BloomSpacing.sectionGap),
        ],
        _AveragesCard(state: state),
        const SizedBox(height: BloomSpacing.sectionGap),
        if (state.regularity != null)
          _RegularityCard(
            regularity: state.regularity!,
            sampleSize: state.regularitySampleSize,
          ),
        const SizedBox(height: BloomSpacing.sectionGap),
        _SampleSizeFooter(count: state.totalTrackedCycles),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(BloomSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BloomRadii.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: BloomSpacing.s12),
          child,
        ],
      ),
    );
  }
}

class _AveragesCard extends StatelessWidget {
  const _AveragesCard({required this.state});
  final InsightsLoaded state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return _SectionCard(
      title: t.insights.averagesTitle,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _StatTile(
              label: t.insights.averageCycle,
              value: state.averageCycleDays == null
                  ? '—'
                  : t.insights.daysShort(
                      n: state.averageCycleDays!.round().toString(),
                    ),
              tone: BloomColors.phaseFollicular,
            ),
          ),
          const SizedBox(width: BloomSpacing.s16),
          Expanded(
            child: _StatTile(
              label: t.insights.averagePeriod,
              value: state.averagePeriodDays == null
                  ? '—'
                  : t.insights.daysShort(
                      n: state.averagePeriodDays!.round().toString(),
                    ),
              tone: BloomColors.phaseMenstrual,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.tone,
  });
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(height: BloomSpacing.s8),
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: BloomSpacing.s4),
        Text(value, style: theme.textTheme.headlineMedium),
      ],
    );
  }
}

class _RegularityCard extends StatelessWidget {
  const _RegularityCard({required this.regularity, required this.sampleSize});
  final Regularity regularity;
  final int sampleSize;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    final (label, fillRatio, color) = switch (regularity) {
      Regularity.high => (
        t.insights.regularityHigh,
        1.0,
        BloomColors.phaseOvulation,
      ),
      Regularity.medium => (
        t.insights.regularityMedium,
        0.66,
        BloomColors.phaseFollicular,
      ),
      Regularity.low => (
        t.insights.regularityLow,
        0.33,
        BloomColors.phaseLuteal,
      ),
    };

    return _SectionCard(
      title: t.insights.regularityTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.textTheme.headlineSmall),
          const SizedBox(height: BloomSpacing.s12),
          ClipRRect(
            borderRadius: BorderRadius.circular(BloomRadii.pill),
            child: LinearProgressIndicator(
              value: fillRatio,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: BloomSpacing.s8),
          Text(
            t.insights.regularityHint(n: sampleSize.toString()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextPredictionCard extends StatelessWidget {
  const _NextPredictionCard({required this.prediction});
  final PredictionOutput prediction;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final fmt = DateFormat.MMMd();

    final (confidenceLabel, confidenceColor) = switch (prediction.confidence) {
      ConfidenceLevel.high => (
        t.insights.confidenceHigh,
        BloomColors.success,
      ),
      ConfidenceLevel.medium => (
        t.insights.confidenceMedium,
        BloomColors.phaseFollicular,
      ),
      ConfidenceLevel.low => (
        t.insights.confidenceLow,
        BloomColors.phaseLuteal,
      ),
    };

    return _SectionCard(
      title: t.insights.nextPredictionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            t.insights.nextPredictionBody(
              from: fmt.format(prediction.predictedNextStart),
              to: fmt.format(prediction.predictedNextStartRangeEnd),
            ),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: BloomSpacing.s8),
          Text(
            t.insights.ovulationLabel(
              date: fmt.format(prediction.predictedOvulation),
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: BloomSpacing.s16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BloomSpacing.s12,
              vertical: BloomSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: confidenceColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(BloomRadii.pill),
            ),
            child: Text(
              confidenceLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: confidenceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleSizeFooter extends StatelessWidget {
  const _SampleSizeFooter({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Center(
      child: Text(
        t.insights.sampleSize(n: count.toString()),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
