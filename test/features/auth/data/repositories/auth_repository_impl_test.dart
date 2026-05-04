import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycycle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/failures/auth_failure.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockAuthRemoteDataSource remote;
  late MockClock clock;
  late AuthRepositoryImpl repository;

  const testAccount = AuthAccount(
    uid: 'uid-1',
    name: 'Marina',
    email: 'marina@example.com',
    photoUrl: 'https://example.com/avatar.png',
  );

  setUp(() {
    remote = MockAuthRemoteDataSource();
    clock = MockClock();
    when(clock.now).thenReturn(defaultTestNow);
    when(() => remote.upsertIdentity(testAccount, defaultTestNow))
        .thenAnswer((_) async {});
    repository = AuthRepositoryImpl(remote: remote, clock: clock);
  });

  Map<String, dynamic> firestoreUserData({
    String? coupleId,
    String? role,
  }) {
    return <String, dynamic>{
      'name': 'Marina',
      'email': 'marina@example.com',
      'photoUrl': 'https://example.com/avatar.png',
      'coupleId': coupleId,
      'role': role,
      'language': 'ptBr',
      'biometricEnabled': false,
      'createdAt': Timestamp.fromDate(
        defaultTestNow.subtract(const Duration(days: 30)),
      ),
      'updatedAt': Timestamp.fromDate(defaultTestNow),
    };
  }

  group('signInWithGoogle', () {
    test('returns Ok with full profile when Firestore doc exists', () async {
      when(() => remote.signInWithGoogle())
          .thenAnswer((_) async => testAccount);
      when(() => remote.fetchUserData('uid-1')).thenAnswer(
        (_) async => firestoreUserData(coupleId: 'couple-1', role: 'owner'),
      );

      final result = await repository.signInWithGoogle();

      expect(result, isA<Ok<User>>());
      final user = (result as Ok<User>).value;
      expect(user.id, 'uid-1');
      expect(user.coupleId, 'couple-1');
      expect(user.role, UserRole.owner);
    });

    test('returns Ok with minimal user when no Firestore doc', () async {
      when(() => remote.signInWithGoogle())
          .thenAnswer((_) async => testAccount);
      when(() => remote.fetchUserData('uid-1')).thenAnswer((_) async => null);

      final result = await repository.signInWithGoogle();

      expect(result, isA<Ok<User>>());
      final user = (result as Ok<User>).value;
      expect(user.id, 'uid-1');
      expect(user.name, 'Marina');
      expect(user.coupleId, isNull);
      expect(user.role, isNull);
      expect(user.createdAt, defaultTestNow);
      expect(user.updatedAt, defaultTestNow);
    });

    test('returns Err(GoogleSignInCancelled) when user cancels', () async {
      when(() => remote.signInWithGoogle()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      final result = await repository.signInWithGoogle();

      expect(result, isA<Err<User>>());
      expect((result as Err<User>).error, isA<GoogleSignInCancelled>());
    });

    test('wraps non-cancel GoogleSignInException as UnknownAuthFailure',
        () async {
      when(() => remote.signInWithGoogle()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.providerConfigurationError,
        ),
      );

      final result = await repository.signInWithGoogle();

      expect(result, isA<Err<User>>());
      expect((result as Err<User>).error, isA<UnknownAuthFailure>());
    });

    test(
        'returns Err(AuthNetworkFailure) on FirebaseAuthException '
        'network-request-failed', () async {
      when(() => remote.signInWithGoogle())
          .thenThrow(fb.FirebaseAuthException(code: 'network-request-failed'));

      final result = await repository.signInWithGoogle();

      expect(result, isA<Err<User>>());
      expect((result as Err<User>).error, isA<AuthNetworkFailure>());
    });

    test('returns Err(FirebaseAuthError) on other FirebaseAuthException',
        () async {
      when(() => remote.signInWithGoogle()).thenThrow(
        fb.FirebaseAuthException(
          code: 'invalid-credential',
          message: 'token expired',
        ),
      );

      final result = await repository.signInWithGoogle();

      expect(result, isA<Err<User>>());
      final err = (result as Err<User>).error as FirebaseAuthError;
      expect(err.code, 'invalid-credential');
      expect(err.message, 'token expired');
    });

    test('returns Err(UnknownAuthFailure) for unexpected exceptions', () async {
      when(() => remote.signInWithGoogle()).thenThrow(StateError('boom'));

      final result = await repository.signInWithGoogle();

      expect(result, isA<Err<User>>());
      expect((result as Err<User>).error, isA<UnknownAuthFailure>());
    });
  });

  group('signOut', () {
    test('returns Ok on success', () async {
      when(() => remote.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, isA<Ok<void>>());
      verify(() => remote.signOut()).called(1);
    });

    test('returns Err on datasource throw', () async {
      when(() => remote.signOut()).thenThrow(StateError('disk full'));

      final result = await repository.signOut();

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).error, isA<UnknownAuthFailure>());
    });
  });

  group('deleteAccount', () {
    test('returns Ok on success', () async {
      when(() => remote.deleteAccount()).thenAnswer((_) async {});

      final result = await repository.deleteAccount();

      expect(result, isA<Ok<void>>());
      verify(() => remote.deleteAccount()).called(1);
    });

    test('returns Err(FirebaseAuthError) when reauth required', () async {
      when(() => remote.deleteAccount()).thenThrow(
        fb.FirebaseAuthException(code: 'requires-recent-login'),
      );

      final result = await repository.deleteAccount();

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).error, isA<FirebaseAuthError>());
    });
  });

  group('watchAuthState', () {
    test('emits Unknown then Unauthenticated when account stream is null',
        () async {
      when(() => remote.watchAuthAccount())
          .thenAnswer((_) => Stream<AuthAccount?>.value(null));

      final states = await repository.watchAuthState().take(2).toList();

      expect(states[0], isA<AuthStateUnknown>());
      expect(states[1], isA<AuthStateUnauthenticated>());
    });

    test(
        'emits Unknown then Authenticated with full profile '
        'when doc exists', () async {
      when(() => remote.watchAuthAccount())
          .thenAnswer((_) => Stream<AuthAccount?>.value(testAccount));
      when(() => remote.watchUserData('uid-1')).thenAnswer(
        (_) => Stream<Map<String, dynamic>?>.value(
          firestoreUserData(coupleId: 'couple-1', role: 'partner'),
        ),
      );

      final states = await repository.watchAuthState().take(2).toList();

      expect(states[0], isA<AuthStateUnknown>());
      expect(states[1], isA<AuthStateAuthenticated>());
      final user = (states[1] as AuthStateAuthenticated).user;
      expect(user.id, 'uid-1');
      expect(user.coupleId, 'couple-1');
      expect(user.role, UserRole.partner);
    });

    test(
        'emits Authenticated with minimal user when no doc exists '
        '(first-time sign-in)', () async {
      when(() => remote.watchAuthAccount())
          .thenAnswer((_) => Stream<AuthAccount?>.value(testAccount));
      when(() => remote.watchUserData('uid-1'))
          .thenAnswer((_) => Stream<Map<String, dynamic>?>.value(null));

      final states = await repository.watchAuthState().take(2).toList();

      expect(states[1], isA<AuthStateAuthenticated>());
      final user = (states[1] as AuthStateAuthenticated).user;
      expect(user.coupleId, isNull);
      expect(user.role, isNull);
      expect(user.createdAt, defaultTestNow);
    });

    test(
        're-emits Authenticated when the user doc updates '
        '(e.g. onboarding completes)', () async {
      when(() => remote.watchAuthAccount())
          .thenAnswer((_) => Stream<AuthAccount?>.value(testAccount));
      when(() => remote.watchUserData('uid-1')).thenAnswer(
        (_) => Stream<Map<String, dynamic>?>.fromIterable(
          <Map<String, dynamic>?>[
          null,
          firestoreUserData(coupleId: 'couple-1', role: 'owner'),
        ]),
      );

      final states = await repository.watchAuthState().take(3).toList();

      expect(states[0], isA<AuthStateUnknown>());
      expect((states[1] as AuthStateAuthenticated).user.coupleId, isNull);
      expect((states[2] as AuthStateAuthenticated).user.coupleId, 'couple-1');
      expect((states[2] as AuthStateAuthenticated).user.role, UserRole.owner);
    });
  });
}
