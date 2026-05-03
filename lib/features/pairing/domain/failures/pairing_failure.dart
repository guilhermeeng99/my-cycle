import 'package:mycycle/core/errors/app_failure.dart';

sealed class PairingFailure extends AppFailure {
  const PairingFailure();
}

final class InvalidInviteCode extends PairingFailure {
  const InvalidInviteCode();
  @override
  String get debugMessage => 'Invite code is invalid or unknown';
}

final class ExpiredInviteCode extends PairingFailure {
  const ExpiredInviteCode();
  @override
  String get debugMessage => 'Invite code expired';
}

final class CoupleFull extends PairingFailure {
  const CoupleFull();
  @override
  String get debugMessage => 'Couple already has both members';
}

final class AlreadyInCouple extends PairingFailure {
  const AlreadyInCouple();
  @override
  String get debugMessage => 'User is already part of a couple';
}

final class PairingNetworkFailure extends PairingFailure {
  const PairingNetworkFailure();
  @override
  String get debugMessage => 'Network error during pairing';
}

final class PairingStorageFailure extends PairingFailure {
  const PairingStorageFailure(this.code);
  final String code;
  @override
  String get debugMessage => 'Pairing storage error [$code]';
}

final class UnknownPairingFailure extends PairingFailure {
  const UnknownPairingFailure(this.cause);
  final Object cause;
  @override
  String get debugMessage => 'Unknown pairing failure: $cause';
}
