import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mycycle/design_system/components/components.dart';
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
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BloomSpacing.screenEdge,
              ),
              child: switch (state) {
                OwnerOnboardingEditing(:final step, :final data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _TopBar(step: step),
                    Expanded(child: _StepBody(step: step, data: data)),
                  ],
                ),
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
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.step});
  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWelcome = step == OnboardingStep.welcome;
    return Padding(
      padding: const EdgeInsets.only(top: BloomSpacing.s8),
      child: Row(
        children: <Widget>[
          if (!isWelcome)
            Material(
              color: theme.colorScheme.surface,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.read<OwnerOnboardingCubit>().back(),
                child: const Padding(
                  padding: EdgeInsets.all(BloomSpacing.s12),
                  child: Icon(BloomIcons.chevronLeft, size: 14),
                ),
              ),
            ),
          const Spacer(),
          if (!isWelcome) _ProgressDots(step: step),
          const Spacer(),
          if (!isWelcome) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step});
  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepIndex = OnboardingStep.values.indexOf(step);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 1; i < OnboardingStep.values.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == stepIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= stepIndex
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
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
    final primary = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Spacer(flex: 2),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(BloomIcons.sparkle, size: 36, color: primary),
          ),
        ),
        const SizedBox(height: BloomSpacing.s32),
        Text(
          t.onboarding.welcomeTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: BloomSpacing.s16),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: BloomSpacing.s16),
          child: Text(
            t.onboarding.welcomeBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(flex: 3),
        BloomPrimaryButton(
          label: t.onboarding.getStarted,
          onPressed: () => context.read<OwnerOnboardingCubit>().next(),
        ),
        const SizedBox(height: BloomSpacing.s16),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BloomSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: BloomSpacing.s8),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
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
        _StepHeader(
          title: t.onboarding.lastPeriodTitle,
          body: t.onboarding.lastPeriodBody,
        ),
        const SizedBox(height: BloomSpacing.s8),
        Material(
          color: theme.colorScheme.surface,
          borderRadius: BloomRadii.card,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selected ?? DateTime.now(),
                firstDate:
                    DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) cubit.setLastPeriodStart(picked);
            },
            child: Padding(
              padding: const EdgeInsets.all(BloomSpacing.s20),
              child: Row(
                children: <Widget>[
                  Icon(
                    BloomIcons.calendar,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: BloomSpacing.s16),
                  Expanded(
                    child: Text(
                      selected == null
                          ? t.onboarding.pickDate
                          : formatter.format(selected),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: selected == null
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                        fontWeight: selected != null
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    BloomIcons.chevronRight,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (daysAgo != null && daysAgo > 60) ...<Widget>[
          const SizedBox(height: BloomSpacing.s12),
          Text(
            t.onboarding.longAgoHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const Spacer(),
        BloomPrimaryButton(
          label: t.common.next,
          onPressed: selected == null ? null : cubit.next,
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
        _StepHeader(
          title: t.onboarding.cycleLengthTitle,
          body: t.onboarding.cycleLengthBody,
        ),
        const Spacer(flex: 2),
        Center(
          child: Text(
            t.onboarding.daysCount(n: data.defaultCycleLength),
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: BloomSpacing.s24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BloomSpacing.s8),
          child: Slider(
            min: 21,
            max: 45,
            divisions: 24,
            value: data.defaultCycleLength.toDouble(),
            onChanged: (v) => cubit.setCycleLength(v.round()),
          ),
        ),
        const Spacer(flex: 3),
        BloomPrimaryButton(label: t.common.next, onPressed: cubit.next),
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
    final cubit = context.read<OwnerOnboardingCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _StepHeader(
          title: t.onboarding.notificationsTitle,
          body: t.onboarding.notificationsBody,
        ),
        const SizedBox(height: BloomSpacing.s8),
        BloomGroupedList(
          children: <Widget>[
            BloomSettingsTile(
              icon: BloomIcons.bell,
              title: t.onboarding.notificationsToggle,
              trailing: Switch.adaptive(
                value: data.notificationsEnabled,
                onChanged: (v) =>
                    cubit.setNotificationsEnabled(enabled: v),
              ),
            ),
          ],
        ),
        const Spacer(),
        BloomPrimaryButton(
          label: t.onboarding.finish,
          icon: BloomIcons.heart,
          onPressed: cubit.next,
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
        BloomPrimaryButton(
          label: t.common.retry,
          onPressed: () => context.read<OwnerOnboardingCubit>().submit(),
        ),
      ],
    );
  }
}
