import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/pairing/data/datasources/couple_remote_datasource.dart';
import 'package:mycycle/features/pairing/data/models/couple_model.dart';
import 'package:mycycle/features/pairing/domain/entities/invite_code.dart';
import 'package:mycycle/features/pairing/domain/failures/pairing_failure.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';
import 'package:mycycle/features/pairing/domain/usecases/invite_code_generator.dart';

class CoupleRepositoryImpl implements CoupleRepository {
  CoupleRepositoryImpl({
    required CoupleRemoteDataSource remote,
    required Clock clock,
  })  : _remote = remote,
        _clock = clock;

  final CoupleRemoteDataSource _remote;
  final Clock _clock;

  static const Duration _inviteTtl = Duration(hours: 24);

  @override
  Stream<Couple?> watchCouple(String coupleId) {
    return _remote.watchCouple(coupleId).map((data) {
      if (data == null) return null;
      return CoupleModel.fromMap(data, coupleId);
    });
  }

  @override
  Future<Result<InviteCode>> generateInviteCode(String coupleId) async {
    try {
      final now = _clock.now();
      final expiresAt = now.add(_inviteTtl);
      final code = InviteCodeGenerator.generate();
      await _remote.writeInviteCode(
        coupleId: coupleId,
        code: code,
        expiresAt: expiresAt,
        updatedAt: now,
      );
      return Ok<InviteCode>(InviteCode(code: code, expiresAt: expiresAt));
    } on FirebaseException catch (e, stack) {
      debugPrint('generateInviteCode failed: [${e.code}] ${e.message}\n$stack');
      return Err<InviteCode>(PairingStorageFailure(e.code));
    } on Object catch (e, stack) {
      debugPrint('generateInviteCode unexpected: $e\n$stack');
      return Err<InviteCode>(UnknownPairingFailure(e));
    }
  }

  @override
  Future<Result<Couple>> redeemInviteCode({
    required String partnerId,
    required String code,
  }) async {
    if (!InviteCodeGenerator.isValidFormat(code)) {
      return const Err<Couple>(InvalidInviteCode());
    }
    try {
      final now = _clock.now();
      final snap = await _remote.redeemInviteCode(
        partnerId: partnerId,
        code: code,
        now: now,
      );
      return Ok<Couple>(CoupleModel.fromMap(snap.data, snap.id));
    } on RedeemException catch (e) {
      return switch (e.error) {
        RedeemError.invalid => const Err<Couple>(InvalidInviteCode()),
        RedeemError.expired => const Err<Couple>(ExpiredInviteCode()),
        RedeemError.full => const Err<Couple>(CoupleFull()),
      };
    } on FirebaseException catch (e, stack) {
      debugPrint('redeemInviteCode failed: [${e.code}] ${e.message}\n$stack');
      return Err<Couple>(PairingStorageFailure(e.code));
    } on Object catch (e, stack) {
      debugPrint('redeemInviteCode unexpected: $e\n$stack');
      return Err<Couple>(UnknownPairingFailure(e));
    }
  }

  @override
  Future<Result<void>> leaveCouple({
    required String coupleId,
    required String userId,
  }) async {
    try {
      await _remote.leaveCouple(
        coupleId: coupleId,
        userId: userId,
        updatedAt: _clock.now(),
      );
      return const Ok<void>(null);
    } on FirebaseException catch (e, stack) {
      debugPrint('leaveCouple failed: [${e.code}] ${e.message}\n$stack');
      return Err<void>(PairingStorageFailure(e.code));
    } on Object catch (e, stack) {
      debugPrint('leaveCouple unexpected: $e\n$stack');
      return Err<void>(UnknownPairingFailure(e));
    }
  }
}
