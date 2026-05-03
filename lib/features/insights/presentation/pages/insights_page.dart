import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
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
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<InsightsCubit, InsightsState>(
          builder: (context, state) => switch (state) {
            InsightsLoading() =>
              const Center(child: CircularProgressIndicator()),
            InsightsEmpty() => _EmptyState(title: t.insights.title),
            InsightsLoaded() =>
              _LoadedBody(state: state, title: t.insights.title),
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Column(
      children: <Widget>[
        BloomLargeHeader(title: title),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BloomSpacing.screenEdge,
            ),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 2),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child:
                      Icon(BloomIcons.sparkle, size: 32, color: primary),
                ),
                const SizedBox(height: BloomSpacing.s24),
                Text(
                  t.insights.emptyTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: BloomSpacing.s12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BloomSpacing.s16,
                  ),
                  child: Text(
                    t.insights.emptyBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state, required this.title});

  final InsightsLoaded state;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: <Widget>[
        BloomLargeHeader(title: title),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.screenEdge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (state.prediction != null) ...<Widget>[
                _NextPredictionCard(prediction: state.prediction!),
                const SizedBox(height: BloomSpacing.s16),
              ],
              _AveragesCard(state: state),
              if (state.regularity != null) ...<Widget>[
                const SizedBox(height: BloomSpacing.s16),
                _RegularityCard(
                  regularity: state.regularity!,
                  sampleSize: state.regularitySampleSize,
                ),
              ],
              const SizedBox(height: BloomSpacing.s24),
              Center(
                child: Text(
                  t.insights.sampleSize(n: state.totalTrackedCycles.toString()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BloomSpacing.s4,
        0,
        BloomSpacing.s4,
        BloomSpacing.s8,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w600,
        ),
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
    final primary = theme.colorScheme.primary;
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.MMMd(locale);

    final (confidenceLabel, confidenceColor) = switch (prediction.confidence) {
      ConfidenceLevel.high => (
        t.insights.confidenceHigh,
        BloomColors.sage,
      ),
      ConfidenceLevel.medium => (
        t.insights.confidenceMedium,
        BloomColors.honey,
      ),
      ConfidenceLevel.low => (
        t.insights.confidenceLow,
        BloomColors.whisperGray,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(label: t.insights.nextPredictionTitle),
        Container(
          padding: const EdgeInsets.all(BloomSpacing.s20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                primary.withValues(alpha: 0.10),
                primary.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BloomRadii.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                t.insights.nextPredictionBody(
                  from: fmt.format(prediction.predictedNextStart),
                  to: fmt.format(prediction.predictedNextStartRangeEnd),
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: BloomColors.phaseMenstrual,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
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
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: confidenceColor.withValues(alpha: 0.16),
                  borderRadius: BloomRadii.pillShape,
                ),
                child: Text(
                  confidenceLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: confidenceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AveragesCard extends StatelessWidget {
  const _AveragesCard({required this.state});
  final InsightsLoaded state;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(label: t.insights.averagesTitle),
        Container(
          padding: const EdgeInsets.all(BloomSpacing.s20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BloomRadii.card,
          ),
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
              Container(
                width: 0.5,
                height: 64,
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
              ),
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
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BloomSpacing.s8),
      child: Column(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          const SizedBox(height: BloomSpacing.s12),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: BloomSpacing.s4),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: tone,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
        BloomColors.sage,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(label: t.insights.regularityTitle),
        Container(
          padding: const EdgeInsets.all(BloomSpacing.s20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BloomRadii.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: BloomSpacing.s12),
              ClipRRect(
                borderRadius: BorderRadius.circular(BloomRadii.pill),
                child: LinearProgressIndicator(
                  value: fillRatio,
                  minHeight: 6,
                  backgroundColor:
                      theme.colorScheme.outline.withValues(alpha: 0.3),
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
        ),
      ],
    );
  }
}
