import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mycycle/core/entities/couple.dart';

class CoupleModel extends Couple {
  const CoupleModel({
    required super.id,
    required super.ownerId,
    required super.createdAt,
    required super.updatedAt,
    super.partnerId,
    super.inviteCode,
    super.inviteExpiresAt,
    super.defaultCycleLength,
    super.defaultLutealLength,
  });

  factory CoupleModel.fromMap(Map<String, dynamic> data, String id) {
    return CoupleModel(
      id: id,
      ownerId: data['ownerId'] as String,
      partnerId: data['partnerId'] as String?,
      inviteCode: data['inviteCode'] as String?,
      inviteExpiresAt: _parseDateTime(data['inviteExpiresAt']),
      defaultCycleLength: data['defaultCycleLength'] as int? ?? 28,
      defaultLutealLength: data['defaultLutealLength'] as int? ?? 14,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
