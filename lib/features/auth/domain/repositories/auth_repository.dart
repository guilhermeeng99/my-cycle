import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';

abstract class AuthRepository {
  Stream<AuthState> watchAuthState();
  Future<Result<User>> signInWithGoogle();
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
}
