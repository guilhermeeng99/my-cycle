import 'package:mycycle/core/errors/app_failure.dart';

sealed class AuthFailure extends AppFailure {
  const AuthFailure();
}

/// User dismissed the Google sign-in dialog. Treat as silent — no UI error.
final class GoogleSignInCancelled extends AuthFailure {
  const GoogleSignInCancelled();

  @override
  String get debugMessage => 'Google sign-in cancelled by user';
}

/// Network error during sign-in or auth state check. Retryable.
final class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure();

  @override
  String get debugMessage => 'Network error during authentication';
}

/// Firebase Auth returned an error not covered by more specific cases.
final class FirebaseAuthError extends AuthFailure {
  const FirebaseAuthError(this.code, this.message);

  final String code;
  final String message;

  @override
  String get debugMessage => 'Firebase auth error [$code]: $message';
}

/// Catch-all for unexpected exceptions during auth flows.
final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure(this.cause);

  final Object cause;

  @override
  String get debugMessage => 'Unknown auth failure: $cause';
}
