import 'package:equatable/equatable.dart';

import 'package:mycycle/core/entities/user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial state before the first auth check completes.
final class AuthStateUnknown extends AuthState {
  const AuthStateUnknown();
}

/// No Firebase session exists.
final class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// User is signed in. [user] may have null [User.coupleId] / [User.role] if
/// the user hasn't completed onboarding/pairing yet — the router decides
/// where they go.
final class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => <Object?>[user];
}
