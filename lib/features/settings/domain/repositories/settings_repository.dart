import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';

abstract class SettingsRepository {
  Future<Result<void>> updateLanguage({
    required String userId,
    required AppLanguage language,
  });

  Future<Result<void>> updateNotificationsEnabled({
    required String userId,
    required bool enabled,
  });

  Future<Result<void>> updateBiometricEnabled({
    required String userId,
    required bool enabled,
  });

  /// Updates the couple's default cycle / luteal length. Owner-only —
  /// enforced by Firestore rules.
  Future<Result<void>> updateCycleDefaults({
    required String coupleId,
    int? defaultCycleLength,
    int? defaultLutealLength,
  });
}
