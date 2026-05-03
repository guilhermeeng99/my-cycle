import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/app_failure.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required FirebaseFirestore firestore,
    required Clock clock,
  })  : _firestore = firestore,
        _clock = clock;

  final FirebaseFirestore _firestore;
  final Clock _clock;

  @override
  Future<Result<void>> updateLanguage({
    required String userId,
    required AppLanguage language,
  }) {
    return _updateUserField(
      userId: userId,
      field: 'language',
      value: language.name,
    );
  }

  @override
  Future<Result<void>> updateNotificationsEnabled({
    required String userId,
    required bool enabled,
  }) {
    return _updateUserField(
      userId: userId,
      field: 'notificationsEnabled',
      value: enabled,
    );
  }

  @override
  Future<Result<void>> updateBiometricEnabled({
    required String userId,
    required bool enabled,
  }) {
    return _updateUserField(
      userId: userId,
      field: 'biometricEnabled',
      value: enabled,
    );
  }

  @override
  Future<Result<void>> updateCycleDefaults({
    required String coupleId,
    int? defaultCycleLength,
    int? defaultLutealLength,
  }) async {
    if (defaultCycleLength == null && defaultLutealLength == null) {
      return const Ok<void>(null);
    }
    final patch = <String, dynamic>{
      'defaultCycleLength': ?defaultCycleLength,
      'defaultLutealLength': ?defaultLutealLength,
      'updatedAt': Timestamp.fromDate(_clock.now()),
    };
    try {
      await _firestore.collection('couples').doc(coupleId).update(patch);
      return const Ok<void>(null);
    } on FirebaseException catch (e, stack) {
      debugPrint(
        'Cycle defaults update failed: [${e.code}] ${e.message}\n$stack',
      );
      return Err<void>(_SettingsStorageFailure(e.code));
    } on Object catch (e, stack) {
      debugPrint('Cycle defaults update unexpected: $e\n$stack');
      return Err<void>(_SettingsStorageFailure(e.toString()));
    }
  }

  Future<Result<void>> _updateUserField({
    required String userId,
    required String field,
    required Object? value,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update(<String, dynamic>{
        field: value,
        'updatedAt': Timestamp.fromDate(_clock.now()),
      });
      return const Ok<void>(null);
    } on FirebaseException catch (e, stack) {
      debugPrint(
        'Settings update($field) failed: [${e.code}] ${e.message}\n$stack',
      );
      return Err<void>(_SettingsStorageFailure(e.code));
    } on Object catch (e, stack) {
      debugPrint('Settings update($field) unexpected: $e\n$stack');
      return Err<void>(_SettingsStorageFailure(e.toString()));
    }
  }
}

class _SettingsStorageFailure extends AppFailure {
  const _SettingsStorageFailure(this.code);
  final String code;
  @override
  String get debugMessage => 'Settings storage error: $code';
}
