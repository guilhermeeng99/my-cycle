import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/auth/presentation/cubits/auth_cubit.dart';

import '../../../../harness/factories/user_factory.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
  });

  group('AuthCubit', () {
    test('starts at AuthStateUnknown when stream is empty', () async {
      when(() => repository.watchAuthState())
          .thenAnswer((_) => const Stream<AuthState>.empty());

      final cubit = AuthCubit(repository: repository);

      expect(cubit.state, isA<AuthStateUnknown>());
      await cubit.close();
    });

    blocTest<AuthCubit, AuthState>(
      'emits states from the repository stream in order',
      setUp: () {
        when(() => repository.watchAuthState()).thenAnswer(
          (_) => Stream<AuthState>.fromIterable(<AuthState>[
            const AuthStateUnauthenticated(),
            AuthStateAuthenticated(UserFactory.unpaired()),
          ]),
        );
      },
      build: () => AuthCubit(repository: repository),
      expect: () => <AuthState>[
        const AuthStateUnauthenticated(),
        AuthStateAuthenticated(UserFactory.unpaired()),
      ],
    );

    test('signInWithGoogle delegates to repository and returns result',
        () async {
      when(() => repository.watchAuthState())
          .thenAnswer((_) => const Stream<AuthState>.empty());
      when(() => repository.signInWithGoogle())
          .thenAnswer((_) async => Ok<User>(UserFactory.unpaired()));
      final cubit = AuthCubit(repository: repository);

      final result = await cubit.signInWithGoogle();

      expect(result, isA<Ok<User>>());
      verify(() => repository.signInWithGoogle()).called(1);
      await cubit.close();
    });

    test('signOut delegates to repository', () async {
      when(() => repository.watchAuthState())
          .thenAnswer((_) => const Stream<AuthState>.empty());
      when(() => repository.signOut())
          .thenAnswer((_) async => const Ok<void>(null));
      final cubit = AuthCubit(repository: repository);

      final result = await cubit.signOut();

      expect(result, isA<Ok<void>>());
      verify(() => repository.signOut()).called(1);
      await cubit.close();
    });

    test('deleteAccount delegates to repository', () async {
      when(() => repository.watchAuthState())
          .thenAnswer((_) => const Stream<AuthState>.empty());
      when(() => repository.deleteAccount())
          .thenAnswer((_) async => const Ok<void>(null));
      final cubit = AuthCubit(repository: repository);

      final result = await cubit.deleteAccount();

      expect(result, isA<Ok<void>>());
      verify(() => repository.deleteAccount()).called(1);
      await cubit.close();
    });
  });
}
