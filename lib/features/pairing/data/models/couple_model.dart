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

  factory CoupleModel.fromCacheJson(Map<String, dynamic> json) {
    DateTime? millisToDate(Object? value) =>
        value is int ? DateTime.fromMillisecondsSinceEpoch(value) : null;
    return CoupleModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      partnerId: json['partnerId'] as String?,
      inviteCode: json['inviteCode'] as String?,
      inviteExpiresAt: millisToDate(json['inviteExpiresAt']),
      defaultCycleLength: json['defaultCycleLength'] as int? ?? 28,
      defaultLutealLength: json['defaultLutealLength'] as int? ?? 14,
      createdAt: millisToDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: millisToDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

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

  Map<String, dynamic> toCacheJson() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
      'partnerId': partnerId,
      'inviteCode': inviteCode,
      'inviteExpiresAt': inviteExpiresAt?.millisecondsSinceEpoch,
      'defaultCycleLength': defaultCycleLength,
      'defaultLutealLength': defaultLutealLength,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
