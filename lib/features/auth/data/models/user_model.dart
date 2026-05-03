import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mycycle/core/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    super.photoUrl,
    super.coupleId,
    super.role,
    super.language,
    super.biometricEnabled,
    super.notificationsEnabled,
  });

  factory UserModel.fromCacheJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      coupleId: json['coupleId'] as String?,
      role: _parseRole(json['role'] as String?),
      language: _parseLanguage(json['language'] as String?),
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int? ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['updatedAt'] as int? ?? 0,
      ),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      coupleId: data['coupleId'] as String?,
      role: _parseRole(data['role'] as String?),
      language: _parseLanguage(data['language'] as String?),
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? false,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'coupleId': coupleId,
      'role': role?.name,
      'language': language.name,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// JSON-encodable shape used by the Hive cache. Replaces [Timestamp]
  /// with millis-since-epoch so it survives `jsonEncode`.
  Map<String, dynamic> toCacheJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'coupleId': coupleId,
      'role': role?.name,
      'language': language.name,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static UserRole? _parseRole(String? value) {
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.partner,
    );
  }

  static AppLanguage _parseLanguage(String? value) {
    if (value == null) return AppLanguage.ptBr;
    return AppLanguage.values.firstWhere(
      (lang) => lang.name == value,
      orElse: () => AppLanguage.ptBr,
    );
  }

  static DateTime _parseDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
