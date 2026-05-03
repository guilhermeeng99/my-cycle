import 'package:equatable/equatable.dart';

/// A couple — owner + (optional) partner. Hosts cycle data via subcollections.
class Couple extends Equatable {
  const Couple({
    required this.id,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.partnerId,
    this.inviteCode,
    this.inviteExpiresAt,
    this.defaultCycleLength = 28,
    this.defaultLutealLength = 14,
  });

  final String id;
  final String ownerId;
  final String? partnerId;
  final String? inviteCode;
  final DateTime? inviteExpiresAt;
  final int defaultCycleLength;
  final int defaultLutealLength;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPaired => partnerId != null;

  bool get hasActiveInvite =>
      inviteCode != null &&
      inviteExpiresAt != null &&
      inviteExpiresAt!.isAfter(DateTime.now());

  Couple copyWith({
    String? id,
    String? ownerId,
    String? partnerId,
    String? inviteCode,
    DateTime? inviteExpiresAt,
    int? defaultCycleLength,
    int? defaultLutealLength,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Couple(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      partnerId: partnerId ?? this.partnerId,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteExpiresAt: inviteExpiresAt ?? this.inviteExpiresAt,
      defaultCycleLength: defaultCycleLength ?? this.defaultCycleLength,
      defaultLutealLength: defaultLutealLength ?? this.defaultLutealLength,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        partnerId,
        inviteCode,
        inviteExpiresAt,
        defaultCycleLength,
        defaultLutealLength,
        createdAt,
        updatedAt,
      ];
}
