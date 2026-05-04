import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';

/// Lightweight DTO carrying the Firebase Auth identity (uid + profile claims
/// from Google). Used as a boundary type so the repository doesn't depend on
/// `firebase_auth.User` directly — keeps unit tests fast.
class AuthAccount {
  const AuthAccount({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
}

/// Wraps Firebase Auth + Google Sign-In + the `users/{uid}` Firestore doc.
///
/// The repository pulls auth events and user-profile data through this seam,
/// allowing fast unit tests via mocktail.
abstract class AuthRemoteDataSource {
  /// Emits an [AuthAccount] for each auth state change. `null` = signed out.
  Stream<AuthAccount?> watchAuthAccount();

  /// Triggers the Google sign-in flow and federates with Firebase Auth.
  /// Throws [GoogleSignInException] on cancel / configuration errors.
  /// Throws [fb.FirebaseAuthException] on Firebase failures.
  Future<AuthAccount> signInWithGoogle();

  Future<void> signOut();

  /// Deletes the Firestore user doc and revokes the Firebase auth credential.
  Future<void> deleteAccount();

  /// One-shot fetch of `users/{uid}`. Returns `null` if the document doesn't
  /// exist (typical for first-time users before onboarding completes).
  Future<Map<String, dynamic>?> fetchUserData(String uid);

  /// Merges `name`, `email`, `photoUrl`, `updatedAt` (and `createdAt` if the
  /// doc is new) into `users/{uid}`. Called on every sign-in so the user doc
  /// always carries identity, even for partners whose doc is first created
  /// by the redemption flow with only coupleId/role.
  Future<void> upsertIdentity(AuthAccount account, DateTime now);

  /// Continuous watch on `users/{uid}`. Emits `null` while the document
  /// doesn't exist; emits the data map on each subsequent update. Used by
  /// the auth repository so the router reacts when onboarding or pairing
  /// completes.
  Stream<Map<String, dynamic>?> watchUserData(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required fb.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthAccount?> watchAuthAccount() {
    return _firebaseAuth.authStateChanges().map(_toAccount);
  }

  @override
  Future<AuthAccount> signInWithGoogle() async {
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google Sign-In returned no ID token');
    }
    final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError('Firebase signInWithCredential returned no user');
    }
    return AuthAccount(
      uid: user.uid,
      name: user.displayName ?? account.displayName ?? '',
      email: user.email ?? account.email,
      photoUrl: user.photoURL ?? account.photoUrl,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
    await _googleSignIn.signOut();
  }

  @override
  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data();
  }

  @override
  Future<void> upsertIdentity(AuthAccount account, DateTime now) async {
    final ref = _firestore.collection('users').doc(account.uid);
    final ts = Timestamp.fromDate(now);
    final exists = (await ref.get()).exists;
    final data = <String, dynamic>{
      'name': account.name,
      'email': account.email,
      'photoUrl': account.photoUrl,
      'updatedAt': ts,
      if (!exists) 'createdAt': ts,
    };
    await ref.set(data, SetOptions(merge: true));
  }

  @override
  Stream<Map<String, dynamic>?> watchUserData(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  AuthAccount? _toAccount(fb.User? user) {
    if (user == null) return null;
    return AuthAccount(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}
