import 'package:mycycle/core/errors/app_failure.dart';

sealed class BiometricFailure extends AppFailure {
  const BiometricFailure();
}

/// Device has no biometric hardware or no enrollment. UI should hide the
/// feature; the lock cannot be enabled in this state.
final class BiometricUnavailable extends BiometricFailure {
  const BiometricUnavailable();
  @override
  String get debugMessage => 'Biometric not available on this device.';
}

/// User dismissed the prompt without authenticating. Counts toward the
/// 3-strike rule but is not a hard error.
final class BiometricCancelled extends BiometricFailure {
  const BiometricCancelled();
  @override
  String get debugMessage => 'Biometric prompt cancelled.';
}

/// Generic platform-level failure (timeout, lockout, etc).
final class BiometricPlatformFailure extends BiometricFailure {
  const BiometricPlatformFailure(this.code);
  final String code;
  @override
  String get debugMessage => 'Biometric platform failure: $code';
}
