import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/biometric/domain/repositories/biometric_repository.dart';

/// Locks the app when it has been backgrounded for more than [_idleThreshold]
/// or whenever the OS resumes from a non-active state — provided the signed-in
/// user has `biometricEnabled = true`.
///
/// Three failed unlock attempts trigger a forced sign-out via
/// `authCubit.signOut()`.
class BiometricLockCubit extends Cubit<BiometricLockState> {
  BiometricLockCubit({
    required AuthCubit authCubit,
    required BiometricRepository biometricRepository,
    required Clock clock,
    Duration idleThreshold = const Duration(minutes: 5),
  }) : _authCubit = authCubit,
       _biometric = biometricRepository,
       _clock = clock,
       _idleThreshold = idleThreshold,
       super(const BiometricLockUnlocked()) {
    _authSub = _authCubit.stream.listen(_onAuthChanged);
  }

  static const int _maxFailedAttempts = 3;

  final AuthCubit _authCubit;
  final BiometricRepository _biometric;
  final Clock _clock;
  final Duration _idleThreshold;

  StreamSubscription<AuthState>? _authSub;
  DateTime? _backgroundedAt;
  int _failedAttempts = 0;

  /// Hook called by the app's lifecycle observer when the app moves out of
  /// the active state.
  void onAppPaused() {
    _backgroundedAt = _clock.now();
  }

  /// Hook called when the app returns to the active state. Locks if the
  /// signed-in user has biometrics enabled and the app was idle past
  /// [_idleThreshold].
  void onAppResumed() {
    final user = _currentUser();
    if (user == null || !user.biometricEnabled) return;
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (since == null) return;
    if (_clock.now().difference(since) >= _idleThreshold) {
      _failedAttempts = 0;
      emit(const BiometricLockLocked());
    }
  }

  /// Manually trigger a lock. Used by the sign-in flow / settings to force
  /// an immediate biometric gate.
  void lock() {
    final user = _currentUser();
    if (user == null || !user.biometricEnabled) return;
    _failedAttempts = 0;
    emit(const BiometricLockLocked());
  }

  Future<void> unlock(String reason) async {
    if (state is! BiometricLockLocked) return;
    final result = await _biometric.authenticate(reason: reason);
    switch (result) {
      case Ok(value: true):
        _failedAttempts = 0;
        emit(const BiometricLockUnlocked());
      case Ok(value: false):
        _registerFailure();
      case Err():
        _registerFailure();
    }
  }

  void _registerFailure() {
    _failedAttempts += 1;
    if (_failedAttempts >= _maxFailedAttempts) {
      emit(const BiometricLockForcedSignOut());
      unawaited(_authCubit.signOut());
      return;
    }
    final remaining = _maxFailedAttempts - _failedAttempts;
    emit(BiometricLockLocked(remainingAttempts: remaining));
  }

  void _onAuthChanged(AuthState authState) {
    if (authState is! AuthStateAuthenticated) {
      _backgroundedAt = null;
      _failedAttempts = 0;
      if (state is! BiometricLockUnlocked) {
        emit(const BiometricLockUnlocked());
      }
    }
  }

  User? _currentUser() {
    final auth = _authCubit.state;
    return auth is AuthStateAuthenticated ? auth.user : null;
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}

sealed class BiometricLockState extends Equatable {
  const BiometricLockState();

  @override
  List<Object?> get props => <Object?>[];
}

final class BiometricLockUnlocked extends BiometricLockState {
  const BiometricLockUnlocked();
}

final class BiometricLockLocked extends BiometricLockState {
  const BiometricLockLocked({this.remainingAttempts = 3});
  final int remainingAttempts;

  @override
  List<Object?> get props => <Object?>[remainingAttempts];
}

/// Terminal: too many failed attempts. The cubit has already triggered
/// `authCubit.signOut()`; the router redirect will route to `/sign-in`
/// once auth flips to unauthenticated.
final class BiometricLockForcedSignOut extends BiometricLockState {
  const BiometricLockForcedSignOut();
}
