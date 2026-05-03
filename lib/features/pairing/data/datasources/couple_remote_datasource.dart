import 'package:cloud_firestore/cloud_firestore.dart';

class CoupleDocSnapshot {
  const CoupleDocSnapshot({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
}

/// Domain-typed errors for the redemption flow. The repository maps these to
/// `PairingFailure`.
enum RedeemError { invalid, expired, full }

class RedeemException implements Exception {
  const RedeemException(this.error);
  final RedeemError error;

  @override
  String toString() => 'RedeemException($error)';
}

abstract class CoupleRemoteDataSource {
  Stream<Map<String, dynamic>?> watchCouple(String coupleId);

  Future<void> writeInviteCode({
    required String coupleId,
    required String code,
    required DateTime expiresAt,
    required DateTime updatedAt,
  });

  /// Atomically: clear the couple's invite code and set its `partnerId`,
  /// while updating the partner's user doc with `coupleId` + `role: partner`.
  /// Throws [RedeemException] on invalid/expired/full conditions.
  Future<CoupleDocSnapshot> redeemInviteCode({
    required String partnerId,
    required String code,
    required DateTime now,
  });

  /// Sets `partnerId = null` on the couple (rules require the caller to be
  /// the current partner) and clears the user's `coupleId` + `role`.
  Future<void> leaveCouple({
    required String coupleId,
    required String userId,
    required DateTime updatedAt,
  });
}

class CoupleRemoteDataSourceImpl implements CoupleRemoteDataSource {
  CoupleRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<Map<String, dynamic>?> watchCouple(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  @override
  Future<void> writeInviteCode({
    required String coupleId,
    required String code,
    required DateTime expiresAt,
    required DateTime updatedAt,
  }) async {
    await _firestore.collection('couples').doc(coupleId).update(
      <String, dynamic>{
        'inviteCode': code,
        'inviteExpiresAt': Timestamp.fromDate(expiresAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      },
    );
  }

  @override
  Future<CoupleDocSnapshot> redeemInviteCode({
    required String partnerId,
    required String code,
    required DateTime now,
  }) async {
    final qs = await _firestore
        .collection('couples')
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();
    if (qs.docs.isEmpty) {
      throw const RedeemException(RedeemError.invalid);
    }
    final coupleRef = qs.docs.first.reference;

    final updated = await _firestore.runTransaction<Map<String, dynamic>>((
      tx,
    ) async {
      final fresh = await tx.get(coupleRef);
      final data = fresh.data();
      if (data == null) throw const RedeemException(RedeemError.invalid);
      if (data['inviteCode'] != code) {
        throw const RedeemException(RedeemError.invalid);
      }
      if (data['partnerId'] != null) {
        throw const RedeemException(RedeemError.full);
      }
      final expiresAt = (data['inviteExpiresAt'] as Timestamp?)?.toDate();
      if (expiresAt != null && !now.isBefore(expiresAt)) {
        throw const RedeemException(RedeemError.expired);
      }

      tx
        ..update(coupleRef, <String, dynamic>{
          'partnerId': partnerId,
          'inviteCode': null,
          'inviteExpiresAt': null,
          'updatedAt': Timestamp.fromDate(now),
        })
        ..update(
          _firestore.collection('users').doc(partnerId),
          <String, dynamic>{
            'coupleId': coupleRef.id,
            'role': 'partner',
            'updatedAt': Timestamp.fromDate(now),
          },
        );

      return <String, dynamic>{
        ...data,
        'partnerId': partnerId,
        'inviteCode': null,
        'inviteExpiresAt': null,
      };
    });

    return CoupleDocSnapshot(id: coupleRef.id, data: updated);
  }

  @override
  Future<void> leaveCouple({
    required String coupleId,
    required String userId,
    required DateTime updatedAt,
  }) async {
    final batch = _firestore.batch()
      ..update(
        _firestore.collection('couples').doc(coupleId),
        <String, dynamic>{
          'partnerId': null,
          'updatedAt': Timestamp.fromDate(updatedAt),
        },
      )
      ..update(
        _firestore.collection('users').doc(userId),
        <String, dynamic>{
          'coupleId': null,
          'role': null,
          'updatedAt': Timestamp.fromDate(updatedAt),
        },
      );
    await batch.commit();
  }
}
