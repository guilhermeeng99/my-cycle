import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/biometric/domain/failures/biometric_failure.dart';
import 'package:mycycle/features/biometric/domain/repositories/biometric_repository.dart';
import 'package:mycycle/features/biometric/presentation/cubits/biometric_lock_cubit.dart';

import '../../../../harness/factories/user_factory.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockBiometric extends Mock implements BiometricRepository {}

class _MutableClock implements Clock {
  _MutableClock(this._now);
  DateTime _now;
  @override
  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}

Future<AuthCubit> _authCubit(_MockAuthRepository repo, AuthState seeded) async {
  when(repo.watchAuthState).thenAnswer(
    (_) => Stream<AuthState>.fromIterable(<AuthState>[seeded])
        .asBroadcastStream(),
  );
  final cubit = AuthCubit(repository: repo);
  await pumpEventQueue();
  return cubit;
}

User _userWithBiometric({required bool enabled}) =>
    UserFactory.owner().copyWith(biometricEnabled: enabled);

void main() {
  late _MockAuthRepository authRepo;
  late _MockBiometric biometric;
  late _MutableClock clock;

  setUp(() {
    authRepo = _MockAuthRepository();
    biometric = _MockBiometric();
    clock = _MutableClock(DateTime.utc(2026, 5, 3, 10));
    when(() => authRepo.signOut())
        .thenAnswer((_) async => const Ok<void>(null));
  });

  test('initial state is Unlocked', () async {
    final auth = await _authCubit(authRepo, const AuthStateUnauthenticated());
    final cubit = BiometricLockCubit(
      authCubit: auth,
      biometricRepository: biometric,
      clock: clock,
    );
    expect(cubit.state, isA<BiometricLockUnlocked>());
  });

  test('does not lock when biometricEnabled is false', () async {
    final auth = await _authCubit(
      authRepo,
      AuthStateAuthenticated(_userWithBiometric(enabled: false)),
    );
    final cubit = BiometricLockCubit(
      authCubit: auth,
      biometricRepository: biometric,
      clock: clock,
    )..onAppPaused();
    clock.advance(const Duration(minutes: 10));
    cubit.onAppResumed();

    expect(cubit.state, isA<BiometricLockUnlocked>());
  });

  test(
    'locks on resume when biometricEnabled and idle past threshold',
    () async {
      final auth = await _authCubit(
        authRepo,
        AuthStateAuthenticated(_userWithBiometric(enabled: true)),
      );
      final cubit = BiometricLockCubit(
        authCubit: auth,
        biometricRepository: biometric,
        clock: clock,
      )..onAppPaused();
      clock.advance(const Duration(minutes: 6));
      cubit.onAppResumed();

      expect(cubit.state, isA<BiometricLockLocked>());
    },
  );

  test('does not lock when idle is below threshold', () async {
    final auth = await _authCubit(
      authRepo,
      AuthStateAuthenticated(_userWithBiometric(enabled: true)),
    );
    final cubit = BiometricLockCubit(
      authCubit: auth,
      biometricRepository: biometric,
      clock: clock,
    )..onAppPaused();
    clock.advance(const Duration(minutes: 1));
    cubit.onAppResumed();

    expect(cubit.state, isA<BiometricLockUnlocked>());
  });

  test('successful unlock returns to Unlocked', () async {
    when(() => biometric.authenticate(reason: any(named: 'reason')))
        .thenAnswer((_) async => const Ok<bool>(true));
    final auth = await _authCubit(
      authRepo,
      AuthStateAuthenticated(_userWithBiometric(enabled: true)),
    );
    final cubit = BiometricLockCubit(
      authCubit: auth,
      biometricRepository: biometric,
      clock: clock,
    )..lock();
    expect(cubit.state, isA<BiometricLockLocked>());

    await cubit.unlock('reason');

    expect(cubit.state, isA<BiometricLockUnlocked>());
  });

  test('three failures trigger forced sign-out and call signOut once',
      () async {
    when(() => biometric.authenticate(reason: any(named: 'reason')))
        .thenAnswer((_) async => const Err<bool>(BiometricCancelled()));
    final auth = await _authCubit(
      authRepo,
      AuthStateAuthenticated(_userWithBiometric(enabled: true)),
    );
    final cubit = BiometricLockCubit(
      authCubit: auth,
      biometricRepository: biometric,
      clock: clock,
    )..lock();

    await cubit.unlock('r');
    await cubit.unlock('r');
    await cubit.unlock('r');

    expect(cubit.state, isA<BiometricLockForcedSignOut>());
    verify(() => authRepo.signOut()).called(1);
  });
}
