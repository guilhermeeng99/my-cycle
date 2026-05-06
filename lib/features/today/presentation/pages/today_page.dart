import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/constants/app_constants.dart';
import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/design_system/components/components.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/logging/domain/usecases/save_day_log.dart';
import 'package:mycycle/features/logging/presentation/widgets/day_log_sheet.dart';
import 'package:mycycle/features/today/presentation/cubits/today_cubit.dart';
import 'package:mycycle/features/today/presentation/widgets/cycle_ring.dart';
import 'package:mycycle/features/today/presentation/widgets/phase_narrative_card.dart';
import 'package:mycycle/features/today/presentation/widgets/today_late_banner.dart';
import 'package:mycycle/features/today/presentation/widgets/upcoming_dates_card.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<TodayCubit, TodayState>(
          builder: (context, state) => switch (state) {
            TodayLoading() => const Center(child: CircularProgressIndicator()),
            TodayEmpty(:final user, :final couple) =>
              _EmptyBody(user: user, couple: couple),
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
    final locale = Localizations.localeOf(context).toString();
    final today = getIt<Clock>().now();
    final dateLabel = DateFormat.MMMMd(locale).format(today);
    final firstName = _firstName(vm.user.name);
    final isPartner = vm.user.role == UserRole.partner;

    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: <Widget>[
        BloomLargeHeader(
          title: isPartner
              ? t.today.partnerHeaderTitle(date: dateLabel)
              : t.today.greeting(name: firstName),
          subtitle: isPartner
              ? t.today.partnerHeaderSubtitle
              : t.today.todayLabel(date: dateLabel),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: BloomSpacing.screenEdge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _WeekStrip(
                today: today,
                onTapDate: (date) => _openLogSheet(
                  context: context,
                  vm: vm,
                  date: date,
                ),
              ),
              const SizedBox(height: BloomSpacing.s32),
              Center(
                child: CycleRing(
                  dayN: vm.dayN,
                  cycleLengthEstimate: vm.cycleLengthEstimate,
                  phase: vm.phase,
                ),
              ),
              const SizedBox(height: BloomSpacing.s32),
              PhaseNarrativeCard(phase: vm.phase),
              const SizedBox(height: BloomSpacing.s12),
              UpcomingDatesCard(
                nextStart: vm.prediction.predictedNextStart,
                nextEnd: vm.prediction.predictedNextStartRangeEnd,
                confidence: vm.prediction.confidence,
                fertileStart: vm.prediction.fertileWindowStart,
                fertileEnd: vm.prediction.fertileWindowEnd,
                ovulation: vm.prediction.predictedOvulation,
              ),
              if (vm.isLatePeriod) ...<Widget>[
                const SizedBox(height: BloomSpacing.s12),
                TodayLateBanner(daysLate: vm.latenessDays),
              ],
              const SizedBox(height: BloomSpacing.s32),
              BloomPrimaryButton(
                label:
                    isPartner ? t.today.partnerNoteCta : t.today.logToday,
                icon: BloomIcons.edit,
                onPressed: () => _openLogSheet(
                  context: context,
                  vm: vm,
                  date: today,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _firstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  Future<void> _openLogSheet({
    required BuildContext context,
    required TodayViewModel vm,
    required DateTime date,
  }) async {
    final saveDayLog = SaveDayLog(
      cycleRepository: getIt<CycleRepository>(),
      dayLogRepository: getIt<DayLogRepository>(),
      clock: getIt<Clock>(),
    );
    final isPartner = vm.user.role == UserRole.partner;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DayLogSheet(
        coupleId: vm.couple.id,
        currentCycleId: isPartner ? null : vm.currentCycle.id,
        date: date,
        saveDayLog: saveDayLog,
        dayLogRepository: getIt<DayLogRepository>(),
        isPartner: isPartner,
      ),
    );
  }
}

/// Day-of-week strip — renders the past 6 days + today as tappable pills.
/// Today is the rightmost pill (selected); tapping any pill opens the log
/// sheet for that date.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.today, required this.onTapDate});

  final DateTime today;
  final ValueChanged<DateTime> onTapDate;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final dayFmt = DateFormat.E(locale);
    final pills = <BloomDayPill>[
      for (var i = 6; i >= 0; i--)
        () {
          final date = today.subtract(Duration(days: i));
          return BloomDayPill(
            date: DateTime(date.year, date.month, date.day),
            dayLabel: _capitalize(dayFmt.format(date)),
            numberLabel: date.day.toString(),
          );
        }(),
    ];

    return BloomDayPillRow(
      pills: pills,
      selected: DateTime(today.year, today.month, today.day),
      onSelected: onTapDate,
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.user, required this.couple});
  final User? user;
  final Couple? couple;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final locale = Localizations.localeOf(context).toString();
    final today = getIt<Clock>().now();
    final dateLabel = DateFormat.MMMMd(locale).format(today);
    final firstName = _firstName(user?.name ?? '');
    final coupleForLog = couple;

    return Column(
      children: <Widget>[
        BloomLargeHeader(
          title: firstName.isEmpty
              ? AppConstants.appName
              : t.today.greeting(name: firstName),
          subtitle: t.today.todayLabel(date: dateLabel),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BloomSpacing.screenEdge,
            ),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 2),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child:
                      Icon(BloomIcons.sparkle, size: 36, color: primary),
                ),
                const SizedBox(height: BloomSpacing.s24),
                Text(
                  t.today.emptyTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: BloomSpacing.s12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BloomSpacing.s16,
                  ),
                  child: Text(
                    t.today.emptyMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 3),
                if (coupleForLog != null)
                  BloomPrimaryButton(
                    label: t.today.emptyCta,
                    icon: BloomIcons.flow,
                    onPressed: () => _openLogSheet(context, coupleForLog),
                  ),
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _firstName(String fullName) {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  Future<void> _openLogSheet(BuildContext context, Couple couple) async {
    final saveDayLog = SaveDayLog(
      cycleRepository: getIt<CycleRepository>(),
      dayLogRepository: getIt<DayLogRepository>(),
      clock: getIt<Clock>(),
    );
    final isPartner = user?.role == UserRole.partner;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DayLogSheet(
        coupleId: couple.id,
        date: getIt<Clock>().now(),
        saveDayLog: saveDayLog,
        dayLogRepository: getIt<DayLogRepository>(),
        isPartner: isPartner,
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
