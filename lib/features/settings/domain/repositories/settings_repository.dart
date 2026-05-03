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
}
