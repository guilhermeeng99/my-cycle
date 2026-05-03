import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mycycle/features/auth/data/models/user_model.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/failures/auth_failure.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required Clock clock,
  })  : _remote = remote,
        _clock = clock;

  final AuthRemoteDataSource _remote;
  final Clock _clock;

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

    controller
      ..onListen = () {
        controller.add(const AuthStateUnknown());
        accountSub = _remote.watchAuthAccount().listen((account) async {
          await userDataSub?.cancel();
          userDataSub = null;

          if (account == null) {
            controller.add(const AuthStateUnauthenticated());
            return;
          }

          userDataSub = _remote.watchUserData(account.uid).listen((docData) {
            controller
                .add(AuthStateAuthenticated(_buildUser(account, docData)));
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
