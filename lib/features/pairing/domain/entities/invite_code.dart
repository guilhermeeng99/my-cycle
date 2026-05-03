import 'package:equatable/equatable.dart';

/// 6-char alphanumeric code that the owner shares with the partner.
class InviteCode extends Equatable {
  const InviteCode({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;

  bool isExpiredAt(DateTime now) => !now.isBefore(expiresAt);

  @override
  List<Object?> get props => [code, expiresAt];
}
