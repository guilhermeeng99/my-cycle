import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/logging/domain/usecases/save_day_log.dart';
import 'package:mycycle/features/logging/presentation/widgets/day_log_sheet.dart';
import 'package:mycycle/features/today/presentation/cubits/today_cubit.dart';
import 'package:mycycle/features/today/presentation/widgets/cycle_ring.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TodayCubit, TodayState>(
          builder: (context, state) {
            final name = switch (state) {
              TodayLoaded(:final vm) => vm.user.name,
              _ => '',
            };
            return Text(
              name.isEmpty ? t.appName : t.today.greeting(name: name),
            );
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<TodayCubit, TodayState>(
          builder: (context, state) => switch (state) {
            TodayLoading() => const Center(child: CircularProgressIndicator()),
            TodayEmpty() => const _EmptyBody(),
            TodayError(:final error) => _ErrorBody(error: error),
            TodayLoaded(:final vm) => _LoadedBody(vm: vm),
          },
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.vm});
  final TodayViewModel vm;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BloomSpacing.screenEdge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: BloomSpacing.s24),
          Center(
            child: CycleRing(
              dayN: vm.dayN,
              cycleLengthEstimate: vm.cycleLengthEstimate,
              phase: vm.phase,
            ),
          ),
          const SizedBox(height: BloomSpacing.sectionGap),
          if (vm.isLatePeriod) _LateBanner(daysLate: vm.latenessDays),
          if (vm.isLatePeriod) const SizedBox(height: BloomSpacing.s16),
          _PredictionCard(
            rangeStart: vm.prediction.predictedNextStart,
            rangeEnd: vm.prediction.predictedNextStartRangeEnd,
            confidence: vm.prediction.confidence,
            reason: vm.prediction.confidenceReason,
          ),
          const SizedBox(height: BloomSpacing.s16),
          _OvulationCard(
            ovulation: vm.prediction.predictedOvulation,
            fertileStart: vm.prediction.fertileWindowStart,
            fertileEnd: vm.prediction.fertileWindowEnd,
          ),
          const SizedBox(height: BloomSpacing.s24),
          ElevatedButton.icon(
            onPressed: () => _openLogSheet(context, vm),
            icon: const Icon(BloomIcons.edit),
            label: Text(t.today.logToday),
          ),
        ],
      ),
    );
  }

  Future<void> _openLogSheet(BuildContext context, TodayViewModel vm) async {
    final saveDayLog = SaveDayLog(
      cycleRepository: getIt<CycleRepository>(),
      dayLogRepository: getIt<DayLogRepository>(),
      clock: getIt<Clock>(),
    );
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DayLogSheet(
        coupleId: vm.couple.id,
        currentCycleId: vm.currentCycle.id,
        date: getIt<Clock>().now(),
        saveDayLog: saveDayLog,
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({
    required this.rangeStart,
    required this.rangeEnd,
    required this.confidence,
    required this.reason,
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final ConfidenceLevel confidence;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.MMMMd(locale);
    return Card(
      color: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BloomRadii.card),
      child: Padding(
        padding: const EdgeInsets.all(BloomSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    t.today.nextPeriodTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                _ConfidencePill(level: confidence),
              ],
            ),
            const SizedBox(height: BloomSpacing.s8),
            Text(
              t.today.aroundRange(
                from: fmt.format(rangeStart),
                to: fmt.format(rangeEnd),
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: BloomSpacing.s8),
            Text(
              reason,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OvulationCard extends StatelessWidget {
  const _OvulationCard({
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
  });

  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.MMMMd(locale);
    return Card(
      color: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BloomRadii.card),
      child: Padding(
        padding: const EdgeInsets.all(BloomSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              t.today.fertileWindowTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: BloomSpacing.s8),
            Text(
              t.today.aroundRange(
                from: fmt.format(fertileStart),
                to: fmt.format(fertileEnd),
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: BloomColors.phaseOvulation,
              ),
            ),
            const SizedBox(height: BloomSpacing.s4),
            Text(
              t.today.ovulationOn(date: fmt.format(ovulation)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  const _ConfidencePill({required this.level});
  final ConfidenceLevel level;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final (label, color) = switch (level) {
      ConfidenceLevel.low => (t.today.confidenceLow, BloomColors.whisperGray),
      ConfidenceLevel.medium => (t.today.confidenceMedium, BloomColors.honey),
      ConfidenceLevel.high => (t.today.confidenceHigh, BloomColors.sage),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.s12,
        vertical: BloomSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BloomRadii.pillShape,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class _LateBanner extends StatelessWidget {
  const _LateBanner({required this.daysLate});
  final int daysLate;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(BloomSpacing.s16),
      decoration: BoxDecoration(
        color: BloomColors.honey.withValues(alpha: 0.15),
        borderRadius: BloomRadii.card,
      ),
      child: Row(
        children: <Widget>[
          const Icon(BloomIcons.clock, color: BloomColors.honey),
          const SizedBox(width: BloomSpacing.s12),
          Expanded(
            child: Text(
              t.today.lateBanner(days: daysLate),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BloomSpacing.screenEdge),
        child: Text(
          t.today.emptyMessage,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BloomSpacing.screenEdge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(BloomIcons.warning, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: BloomSpacing.s16),
            Text(
              t.today.errorGeneric,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
