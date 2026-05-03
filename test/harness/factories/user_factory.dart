import 'package:mycycle/core/entities/user.dart';

/// Default factory time — pinned to a deterministic moment so date-sensitive
/// tests are reproducible.
final DateTime defaultTestNow = DateTime.utc(2026, 5, 3, 10);

abstract final class UserFactory {
  static User make({
    String id = 'test-uid',
    String name = 'Test User',
    String email = 'test@example.com',
    String? photoUrl,
    String? coupleId,
    UserRole? role,
    AppLanguage language = AppLanguage.ptBr,
    bool biometricEnabled = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      photoUrl: photoUrl,
      coupleId: coupleId,
      role: role,
      language: language,
      biometricEnabled: biometricEnabled,
      createdAt: createdAt ?? defaultTestNow,
      updatedAt: updatedAt ?? defaultTestNow,
    );
  }

  /// User who has signed in but hasn't paired yet (no couple).
  static User unpaired() => make();

  /// Owner of a couple.
  static User owner({String coupleId = 'couple-1'}) => make(
        coupleId: coupleId,
        role: UserRole.owner,
      );

  /// Partner in a couple.
  static User partner({String coupleId = 'couple-1'}) => make(
        coupleId: coupleId,
        role: UserRole.partner,
      );
}
