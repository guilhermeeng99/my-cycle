import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/design_system/icons/bloom_icons.dart';
import 'package:mycycle/design_system/tokens/tokens.dart';
import 'package:mycycle/features/onboarding/domain/failures/onboarding_failure.dart';
import 'package:mycycle/features/onboarding/presentation/cubits/owner_onboarding_cubit.dart';
import 'package:mycycle/gen/i18n/strings.g.dart';

class OwnerOnboardingPage extends StatelessWidget {
  const OwnerOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OwnerOnboardingCubit, OwnerOnboardingState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(BloomSpacing.screenEdge),
              child: switch (state) {
                OwnerOnboardingEditing(:final step, :final data) =>
                  _StepBody(step: step, data: data),
                OwnerOnboardingSubmitting() => const _SubmittingBody(),
                OwnerOnboardingError(:final failure) =>
                  _ErrorBody(failure: failure),
                OwnerOnboardingDone() => const _SubmittingBody(),
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    OwnerOnboardingState state,
  ) {
    if (state is! OwnerOnboardingEditing) return null;
    if (state.step == OnboardingStep.welcome) return null;
    return AppBar(
      leading: IconButton(
        icon: const Icon(BloomIcons.arrowLeft),
        onPressed: () => context.read<OwnerOnboardingCubit>().back(),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.step, required this.data});

  final OnboardingStep step;
  final OnboardingFormData data;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      OnboardingStep.welcome => const _WelcomeStep(),
      OnboardingStep.lastPeriod => _LastPeriodStep(data: data),
      OnboardingStep.cycleLength => _CycleLengthStep(data: data),
      OnboardingStep.notifications => _NotificationsStep(data: data),
    };
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Spacer(flex: 2),
        Text(
          t.onboarding.welcomeTitle,
          style: theme.textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BloomSpacing.s16),
        Text(
          t.onboarding.welcomeBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(flex: 3),
        ElevatedButton(
          onPressed: () => context.read<OwnerOnboardingCubit>().next(),
          child: Text(t.onboarding.getStarted),
        ),
        const SizedBox(height: BloomSpacing.s16),
      ],
    );
  }
}

class _LastPeriodStep extends StatelessWidget {
  const _LastPeriodStep({required this.data});
  final OnboardingFormData data;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cubit = context.read<OwnerOnboardingCubit>();
    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat.yMMMMd(locale);
    final selected = data.lastPeriodStart;
    final daysAgo = selected != null
        ? DateTime.now().difference(selected).inDays
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: BloomSpacing.s24),
        Text(
          t.onboarding.lastPeriodTitle,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: BloomSpacing.s12),
        Text(
          t.onboarding.lastPeriodBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: BloomSpacing.s32),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            if (picked != null) cubit.setLastPeriodStart(picked);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: BloomSpacing.s8),
            child: Text(
              selected == null
                  ? t.onboarding.pickDate
                  : formatter.format(selected),
            ),
          ),
        ),
        if (daysAgo != null && daysAgo > 60) ...<Widget>[
          const SizedBox(height: BloomSpacing.s16),
          Text(
            t.onboarding.longAgoHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const Spacer(),
        ElevatedButton(
          onPressed: selected == null ? null : cubit.next,
          child: Text(t.common.next),
        ),
        const SizedBox(height: BloomSpacing.s16),
      ],
    );
  }
}

class _CycleLengthStep extends StatelessWidget {
  const _CycleLengthStep({required this.data});
  final OnboardingFormData data;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cubit = context.read<OwnerOnboardingCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: BloomSpacing.s24),
        Text(
          t.onboarding.cycleLengthTitle,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: BloomSpacing.s12),
        Text(
          t.onboarding.cycleLengthBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: BloomSpacing.s48),
        Center(
          child: Text(
            t.onboarding.daysCount(n: data.defaultCycleLength),
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: BloomSpacing.s16),
        Slider(
          min: 21,
          max: 45,
          divisions: 24,
          value: data.defaultCycleLength.toDouble(),
          onChanged: (v) => cubit.setCycleLength(v.round()),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: cubit.next,
          child: Text(t.common.next),
        ),
        const SizedBox(height: BloomSpacing.s16),
      ],
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({required this.data});
  final OnboardingFormData data;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cubit = context.read<OwnerOnboardingCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: BloomSpacing.s24),
        Text(
          t.onboarding.notificationsTitle,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: BloomSpacing.s12),
        Text(
          t.onboarding.notificationsBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: BloomSpacing.s32),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            t.onboarding.notificationsToggle,
            style: theme.textTheme.bodyLarge,
          ),
          value: data.notificationsEnabled,
          onChanged: (v) => cubit.setNotificationsEnabled(enabled: v),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: cubit.next,
          child: Text(t.onboarding.finish),
        ),
        const SizedBox(height: BloomSpacing.s16),
      ],
    );
  }
}

class _SubmittingBody extends StatelessWidget {
  const _SubmittingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.failure});
  final OnboardingFailure failure;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final message = switch (failure) {
      OnboardingNetworkFailure() => t.onboarding.errorNetwork,
      OnboardingValidationFailure() => t.onboarding.errorValidation,
      _ => t.onboarding.errorGeneric,
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(
          BloomIcons.warning,
          size: 48,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: BloomSpacing.s16),
        Text(
          message,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BloomSpacing.s32),
        ElevatedButton(
          onPressed: () => context.read<OwnerOnboardingCubit>().submit(),
          child: Text(t.common.retry),
        ),
      ],
    );
  }
}
