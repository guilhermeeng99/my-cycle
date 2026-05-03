import 'package:mycycle/core/errors/result.dart';

/// Wraps `local_auth` so the rest of the app never imports the platform
/// package directly. Tests mock this interface.
abstract class BiometricRepository {
  /// True when the device has biometrics enrolled and the platform allows
  /// using them. False on emulators, devices without enrollment, or
  /// unsupported platforms.
  Future<bool> isAvailable();

  /// Prompts the user to authenticate. [reason] is shown as the system
  /// dialog body. Returns `Ok(true)` on success, `Ok(false)` if the user
  /// dismissed (counts toward strikes), or `Err(failure)` on platform
  /// errors.
  Future<Result<bool>> authenticate({required String reason});
}
