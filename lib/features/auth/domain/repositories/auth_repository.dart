import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';

abstract class AuthRepository {
  Stream<AuthState> watchAuthState();
  Future<Result<User>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();

  /// Continuous read on `users/{uid}`. Used to watch the partner's profile
  /// from Settings — the Firestore rules permit couple members to read each
  /// other's user doc. Emits `null` while the doc doesn't exist (e.g., a
  /// freshly-paired partner whose doc is still being written).
  Stream<User?> watchUser(String uid);
}
