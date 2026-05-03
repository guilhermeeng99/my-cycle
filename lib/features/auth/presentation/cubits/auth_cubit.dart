import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';

/// Owns the global auth state.
///
/// Subscribes to the repository's auth-state stream on construction and
/// re-emits each state. Action methods ([signInWithGoogle], [signOut],
/// [deleteAccount]) return [Result] so callers (typically a page) can show
/// inline feedback (loading, error toast) while the stream takes care of
/// driving navigation through the router.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(const AuthStateUnknown()) {
    _subscription = _repository.watchAuthState().listen(emit);
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthState> _subscription;

  Future<Result<User>> signInWithGoogle() => _repository.signInWithGoogle();

  Future<Result<void>> signOut() => _repository.signOut();

  Future<Result<void>> deleteAccount() => _repository.deleteAccount();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
