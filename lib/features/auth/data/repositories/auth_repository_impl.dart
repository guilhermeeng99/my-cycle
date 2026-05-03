import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/core/hive/hive_doc_cache.dart';
import 'package:mycycle/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycycle/features/auth/data/models/user_model.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/failures/auth_failure.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required Clock clock,
    HiveDocCache<User>? userCache,
    Future<void> Function()? onSignOut,
  })  : _remote = remote,
        _clock = clock,
        _userCache = userCache,
        _onSignOut = onSignOut;

  final AuthRemoteDataSource _remote;
  final Clock _clock;
  final HiveDocCache<User>? _userCache;
  final Future<void> Function()? _onSignOut;

  /// Reactive auth + profile state.
  ///
  /// For each Firebase auth change we (re)subscribe to the user's Firestore
  /// doc, so the cubit re-emits whenever the profile changes (sign-in,
  /// onboarding completes, partner pairs). Manual switch-map: cancel the
  /// inner subscription before opening the new one.
  ///
  /// Uses a single-subscription [StreamController] so the initial
  /// `AuthStateUnknown` is buffered until the cubit (or test) subscribes —
  /// broadcast controllers drop pre-subscription events.
  @override
  Stream<AuthState> watchAuthState() {
    StreamSubscription<AuthAccount?>? accountSub;
    StreamSubscription<Map<String, dynamic>?>? userDataSub;
    final controller = StreamController<AuthState>();
    var emittedFromCache = false;

    controller
      ..onListen = () {
        controller.add(const AuthStateUnknown());
        accountSub = _remote.watchAuthAccount().listen((account) async {
          await userDataSub?.cancel();
          userDataSub = null;

          if (account == null) {
            emittedFromCache = false;
            controller.add(const AuthStateUnauthenticated());
            return;
          }

          // Fast paint: yield the cached user before Firestore replies.
          // Firebase auth itself is already cached on disk by the SDK, so
          // the only network step left is reading users/{uid}.
          final cached = _userCache?.read(account.uid);
          if (cached != null && !emittedFromCache) {
            emittedFromCache = true;
            controller.add(AuthStateAuthenticated(cached));
          }

          userDataSub = _remote.watchUserData(account.uid).listen((docData) {
            final user = _buildUser(account, docData);
            unawaited(_userCache?.write(account.uid, user));
            controller.add(AuthStateAuthenticated(user));
          });
        });
      }
      ..onCancel = () async {
        await userDataSub?.cancel();
        await accountSub?.cancel();
      };

    return controller.stream;
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    try {
      final account = await _remote.signInWithGoogle();
      final docData = await _remote.fetchUserData(account.uid);
      return Ok<User>(_buildUser(account, docData));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Err<User>(GoogleSignInCancelled());
      }
      return Err<User>(UnknownAuthFailure(e));
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        return const Err<User>(AuthNetworkFailure());
      }
      return Err<User>(FirebaseAuthError(e.code, e.message ?? ''));
    } on Object catch (e) {
      return Err<User>(UnknownAuthFailure(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      // Wipe every cache so the next user (or this user signing back in)
      // doesn't see the previous session's state on the splash. The hook
      // is wired by the DI container — callers don't need to remember.
      if (_onSignOut != null) await _onSignOut();
      return const Ok<void>(null);
    } on Object catch (e) {
      return Err<void>(UnknownAuthFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remote.deleteAccount();
      return const Ok<void>(null);
    } on fb.FirebaseAuthException catch (e) {
      return Err<void>(FirebaseAuthError(e.code, e.message ?? ''));
    } on Object catch (e) {
      return Err<void>(UnknownAuthFailure(e));
    }
  }

  /// Builds a [User] from the Firebase auth account + (optional) Firestore
  /// profile doc. When the doc is missing (first-time sign-in), constructs a
  /// minimal user from the auth claims — onboarding will write the doc.
  User _buildUser(AuthAccount account, Map<String, dynamic>? docData) {
    if (docData != null) {
      return UserModel.fromMap(docData, account.uid);
    }
    final now = _clock.now();
    return User(
      id: account.uid,
      name: account.name,
      email: account.email,
      photoUrl: account.photoUrl,
      createdAt: now,
      updatedAt: now,
    );
  }
}
