import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/app/di/injection_container.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/calendar/domain/entities/calendar_day.dart';
import 'package:mycycle/features/calendar/presentation/cubits/calendar_cubit.dart';
import 'package:mycycle/features/calendar/presentation/widgets/day_cell.dart';
import 'package:mycycle/features/calendar/presentation/widgets/month_header.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/logging/domain/usecases/save_day_log.dart';
import 'package:mycycle/features/logging/presentation/widgets/day_log_sheet.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({required this.coupleId, super.key});

  final String coupleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, state) => switch (state) {
            CalendarLoading() =>
              const Center(child: CircularProgressIndicator()),
            CalendarError(:final error) => _ErrorBody(error: error),
            CalendarLoaded() => _LoadedBody(state: state, coupleId: coupleId),
          },
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state, required this.coupleId});

  final CalendarLoaded state;
  final String coupleId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CalendarCubit>();
    final clock = getIt<Clock>();
    final today = clock.now();
    final isOnTodayMonth = state.monthAnchor.year == today.year &&
        state.monthAnchor.month == today.month;

    return Column(
      children: <Widget>[
        MonthHeader(
          monthAnchor: state.monthAnchor,
          onPrev: () => cubit.changeMonth(-1),
          onNext: () => cubit.changeMonth(1),
          onToday: cubit.jumpToToday,
          isOnTodayMonth: isOnTodayMonth,
        ),
        const WeekdayHeader(),
        const SizedBox(height: BloomSpacing.s4),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: BloomSpacing.s8,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: state.days.length,
            itemBuilder: (context, index) {
              final day = state.days[index];
              return DayCell(
                day: day,
                onTap: () => _onDayTap(context, day),
              );
            },
          ),
        ),
        const _Legend(),
        const SizedBox(height: 120),
      ],
    );
  }

  Future<void> _onDayTap(BuildContext context, CalendarDay day) async {
    final clock = getIt<Clock>();
    if (day.date.isAfter(clock.now())) return;
    final saveDayLog = SaveDayLog(
      cycleRepository: getIt<CycleRepository>(),
      dayLogRepository: getIt<DayLogRepository>(),
      clock: clock,
    );
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DayLogSheet(
        coupleId: coupleId,
        date: day.date,
        saveDayLog: saveDayLog,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final phases = <(Color, String)>[
      (BloomColors.phaseMenstrual, _phaseLabel(t, CyclePhase.menstrual)),
      (BloomColors.phaseFollicular, _phaseLabel(t, CyclePhase.follicular)),
      (BloomColors.phaseOvulation, _phaseLabel(t, CyclePhase.ovulation)),
      (BloomColors.phaseLuteal, _phaseLabel(t, CyclePhase.luteal)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BloomSpacing.screenEdge,
        vertical: BloomSpacing.s12,
      ),
      child: Wrap(
        spacing: BloomSpacing.s12,
        runSpacing: BloomSpacing.s8,
        alignment: WrapAlignment.center,
        children: <Widget>[
          for (final (color, label) in phases)
            _LegendChip(color: color, label: label),
        ],
      ),
    );
  }

  String _phaseLabel(Translations t, CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstrual => t.today.phaseMenstrual,
      CyclePhase.follicular => t.today.phaseFollicular,
      CyclePhase.ovulation => t.today.phaseOvulation,
      CyclePhase.luteal => t.today.phaseLuteal,
      CyclePhase.unknown => t.today.phaseUnknown,
    };
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: BloomSpacing.s8),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.4,
          ),
        ),
      ],
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
            Icon(
              BloomIcons.warning,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: BloomSpacing.s16),
            Text(
              t.calendar.errorGeneric,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
