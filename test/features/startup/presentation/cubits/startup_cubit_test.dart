import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:mycycle/features/startup/presentation/cubits/startup_cubit.dart';

import '../../../../harness/factories/user_factory.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Builds an [AuthCubit] whose state is already pinned to [seeded] by the
/// time the future resolves. Tests use this when they need the cubit to
/// look "already resolved" before `StartupCubit.initialize()` runs.
Future<AuthCubit> _authCubitInState(
  _MockAuthRepository repository,
  AuthState seeded,
) async {
  when(repository.watchAuthState).thenAnswer(
    (_) =>
        Stream<AuthState>.fromIterable(<AuthState>[seeded]).asBroadcastStream(),
  );
  final cubit = AuthCubit(repository: repository);
  await pumpEventQueue();
  return cubit;
}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
  });

  test('initial state is StartupInitial', () async {
    when(repository.watchAuthState).thenAnswer(
      (_) => const Stream<AuthState>.empty(),
    );
    final auth = AuthCubit(repository: repository);

    final cubit = StartupCubit(authCubit: auth);

    expect(cubit.state, isA<StartupInitial>());
  });

  test(
    'initialize from authenticated auth emits Loading → Authenticated',
    () async {
      final auth = await _authCubitInState(
        repository,
        AuthStateAuthenticated(UserFactory.unpaired()),
      );
      final cubit = StartupCubit(authCubit: auth);

      await cubit.initialize();

      expect(cubit.state, isA<StartupAuthenticated>());
    },
  );

  test(
    'initialize from unauthenticated auth emits Loading → Unauthenticated',
    () async {
      final auth = await _authCubitInState(
        repository,
        const AuthStateUnauthenticated(),
      );
      final cubit = StartupCubit(authCubit: auth);

      await cubit.initialize();

      expect(cubit.state, isA<StartupUnauthenticated>());
    },
  );

  test('initialize waits for AuthCubit to leave Unknown', () async {
    final controller = StreamController<AuthState>.broadcast();
    when(repository.watchAuthState).thenAnswer((_) => controller.stream);
    final auth = AuthCubit(repository: repository);
    final cubit = StartupCubit(authCubit: auth);

    final init = cubit.initialize();
    await pumpEventQueue();
    expect(cubit.state, isA<StartupLoading>());

    controller.add(AuthStateAuthenticated(UserFactory.unpaired()));
    await init;

    expect(cubit.state, isA<StartupAuthenticated>());

    await controller.close();
  });

  test('calling initialize twice is a no-op the second time', () async {
    final auth = await _authCubitInState(
      repository,
      const AuthStateUnauthenticated(),
    );
    final cubit = StartupCubit(authCubit: auth);
    await cubit.initialize();

    final emitted = <StartupState>[];
    final sub = cubit.stream.listen(emitted.add);

    await cubit.initialize();
    await pumpEventQueue();

    expect(emitted, isEmpty);
    expect(cubit.state, isA<StartupUnauthenticated>());

    await sub.cancel();
  });

  test('emits a progress checkpoint while running', () async {
    final auth = await _authCubitInState(
      repository,
      AuthStateAuthenticated(UserFactory.unpaired()),
    );
    final cubit = StartupCubit(authCubit: auth);
    final emitted = <StartupState>[];
    final sub = cubit.stream.listen(emitted.add);

    await cubit.initialize();
    await pumpEventQueue();

    final loadingStates = emitted.whereType<StartupLoading>().toList();
    expect(loadingStates, isNotEmpty);
    expect(emitted.last, isA<StartupAuthenticated>());

    await sub.cancel();
  });
}
