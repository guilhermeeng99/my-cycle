import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/onboarding/domain/failures/onboarding_failure.dart';
import 'package:mycycle/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Mutable form data accumulated across the 5 onboarding steps.
class OnboardingFormData extends Equatable {
  const OnboardingFormData({
    this.lastPeriodStart,
    this.defaultCycleLength = 28,
    this.notificationsEnabled = true,
  });

  final DateTime? lastPeriodStart;
  final int defaultCycleLength;
  final bool notificationsEnabled;

  OnboardingFormData copyWith({
    DateTime? lastPeriodStart,
    int? defaultCycleLength,
    bool? notificationsEnabled,
  }) {
    return OnboardingFormData(
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      defaultCycleLength: defaultCycleLength ?? this.defaultCycleLength,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props =>
      [lastPeriodStart, defaultCycleLength, notificationsEnabled];
}

/// Steps of the owner onboarding flow.
enum OnboardingStep { welcome, lastPeriod, cycleLength, notifications }

sealed class OwnerOnboardingState extends Equatable {
  const OwnerOnboardingState(this.data);
  final OnboardingFormData data;

  @override
  List<Object?> get props => [data];
}

final class OwnerOnboardingEditing extends OwnerOnboardingState {
  const OwnerOnboardingEditing(super.data, this.step);
  final OnboardingStep step;

  @override
  List<Object?> get props => [data, step];
}

final class OwnerOnboardingSubmitting extends OwnerOnboardingState {
  const OwnerOnboardingSubmitting(super.data);
}

final class OwnerOnboardingError extends OwnerOnboardingState {
  const OwnerOnboardingError(super.data, this.failure);
  final OnboardingFailure failure;

  @override
  List<Object?> get props => [data, failure];
}

final class OwnerOnboardingDone extends OwnerOnboardingState {
  const OwnerOnboardingDone(super.data);
}

class OwnerOnboardingCubit extends Cubit<OwnerOnboardingState> {
  OwnerOnboardingCubit({
    required OnboardingRepository repository,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl,
    AppLanguage initialLanguage = AppLanguage.ptBr,
  })  : _repository = repository,
        _language = initialLanguage,
        super(
          const OwnerOnboardingEditing(
            OnboardingFormData(),
            OnboardingStep.welcome,
          ),
        );

  final OnboardingRepository _repository;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  final AppLanguage _language;

  void next() {
    final s = state;
    if (s is! OwnerOnboardingEditing) return;
    final nextStep = switch (s.step) {
      OnboardingStep.welcome => OnboardingStep.lastPeriod,
      OnboardingStep.lastPeriod => OnboardingStep.cycleLength,
      OnboardingStep.cycleLength => OnboardingStep.notifications,
      OnboardingStep.notifications => null,
    };
    if (nextStep == null) {
      unawaited(submit());
      return;
    }
    if (!_canAdvanceFrom(s.step, s.data)) return;
    emit(OwnerOnboardingEditing(s.data, nextStep));
  }

  void back() {
    final s = state;
    if (s is! OwnerOnboardingEditing) return;
    final prev = switch (s.step) {
      OnboardingStep.welcome => null,
      OnboardingStep.lastPeriod => OnboardingStep.welcome,
      OnboardingStep.cycleLength => OnboardingStep.lastPeriod,
      OnboardingStep.notifications => OnboardingStep.cycleLength,
    };
    if (prev == null) return;
    emit(OwnerOnboardingEditing(s.data, prev));
  }

  void setLastPeriodStart(DateTime date) {
    final s = state;
    if (s is! OwnerOnboardingEditing) return;
    emit(
      OwnerOnboardingEditing(
        s.data.copyWith(lastPeriodStart: date),
        s.step,
      ),
    );
  }

  void setCycleLength(int length) {
    final s = state;
    if (s is! OwnerOnboardingEditing) return;
    emit(
      OwnerOnboardingEditing(
        s.data.copyWith(defaultCycleLength: length),
        s.step,
      ),
    );
  }

  void setNotificationsEnabled({required bool enabled}) {
    final s = state;
    if (s is! OwnerOnboardingEditing) return;
    emit(
      OwnerOnboardingEditing(
        s.data.copyWith(notificationsEnabled: enabled),
        s.step,
      ),
    );
  }

  Future<void> submit() async {
    final data = state.data;
    if (data.lastPeriodStart == null) return;

    emit(OwnerOnboardingSubmitting(data));

    final result = await _repository.completeOwnerOnboarding(
      userId: userId,
      name: userName,
      email: userEmail,
      photoUrl: userPhotoUrl,
      lastPeriodStart: data.lastPeriodStart!,
      defaultCycleLength: data.defaultCycleLength,
      notificationsEnabled: data.notificationsEnabled,
      language: _language,
    );

    switch (result) {
      case Ok():
        emit(OwnerOnboardingDone(data));
      case Err(:final error):
        emit(OwnerOnboardingError(data, error as OnboardingFailure));
    }
  }

  bool _canAdvanceFrom(OnboardingStep step, OnboardingFormData data) {
    return switch (step) {
      OnboardingStep.welcome => true,
      OnboardingStep.lastPeriod => data.lastPeriodStart != null,
      OnboardingStep.cycleLength =>
        data.defaultCycleLength >= 21 && data.defaultCycleLength <= 45,
      OnboardingStep.notifications => true,
    };
  }
}
