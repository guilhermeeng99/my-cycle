import 'package:mycycle/core/errors/app_failure.dart';

sealed class OnboardingFailure extends AppFailure {
  const OnboardingFailure();
}

final class OnboardingValidationFailure extends OnboardingFailure {
  const OnboardingValidationFailure(this.field, this.reason);
  final String field;
  final String reason;
  @override
  String get debugMessage => 'Validation failed on $field: $reason';
}

final class OnboardingNetworkFailure extends OnboardingFailure {
  const OnboardingNetworkFailure();
  @override
  String get debugMessage => 'Network error during onboarding submit';
}

final class OnboardingStorageFailure extends OnboardingFailure {
  const OnboardingStorageFailure(this.code, this.message);
  final String code;
  final String message;
  @override
  String get debugMessage => 'Onboarding storage error [$code]: $message';
}

final class UnknownOnboardingFailure extends OnboardingFailure {
  const UnknownOnboardingFailure(this.cause);
  final Object cause;
  @override
  String get debugMessage => 'Unknown onboarding failure: $cause';
}
