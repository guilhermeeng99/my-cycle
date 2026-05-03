import 'package:equatable/equatable.dart';

enum UserRole { owner, partner }

enum AppLanguage { en, ptBr }

/// Application-level user entity. Sourced from Firebase Auth (id/name/email/
/// photoUrl) and Firestore `users/{uid}` (couple linkage, preferences).
///
/// A user without a [coupleId] is signed in but unpaired — the router sends
/// them to the pairing flow.
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.coupleId,
    this.role,
    this.language = AppLanguage.ptBr,
    this.biometricEnabled = false,
    this.notificationsEnabled = false,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? coupleId;
  final UserRole? role;
  final AppLanguage language;
  final bool biometricEnabled;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPaired => coupleId != null && role != null;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? coupleId,
    UserRole? role,
    AppLanguage? language,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      coupleId: coupleId ?? this.coupleId,
      role: role ?? this.role,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        coupleId,
        role,
        language,
        biometricEnabled,
        notificationsEnabled,
        createdAt,
        updatedAt,
      ];
}
