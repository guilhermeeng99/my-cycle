import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/biometric/domain/failures/biometric_failure.dart';
import 'package:mycycle/features/biometric/domain/repositories/biometric_repository.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  BiometricRepositoryImpl({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final enrolled = await _localAuth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException catch (e, stack) {
      debugPrint('Biometric isAvailable failed: ${e.code}\n$stack');
      return false;
    }
  }

  @override
  Future<Result<bool>> authenticate({required String reason}) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return Ok<bool>(ok);
    } on PlatformException catch (e, stack) {
      debugPrint('Biometric authenticate failed: ${e.code}\n$stack');
      // local_auth throws specific codes for not-available paths.
      if (e.code == 'NotAvailable' ||
          e.code == 'NotEnrolled' ||
          e.code == 'PasscodeNotSet') {
        return const Err<bool>(BiometricUnavailable());
      }
      return Err<bool>(BiometricPlatformFailure(e.code));
    }
  }
}
