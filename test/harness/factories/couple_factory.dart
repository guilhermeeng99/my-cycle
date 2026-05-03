import 'package:mycycle/core/entities/couple.dart';

import 'user_factory.dart';

abstract final class CoupleFactory {
  static Couple make({
    String id = 'couple-1',
    String ownerId = 'test-uid',
    String? partnerId,
    String? inviteCode,
    DateTime? inviteExpiresAt,
    int defaultCycleLength = 28,
    int defaultLutealLength = 14,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Couple(
      id: id,
      ownerId: ownerId,
      partnerId: partnerId,
      inviteCode: inviteCode,
      inviteExpiresAt: inviteExpiresAt,
      defaultCycleLength: defaultCycleLength,
      defaultLutealLength: defaultLutealLength,
      createdAt: createdAt ?? defaultTestNow,
      updatedAt: updatedAt ?? defaultTestNow,
    );
  }

  /// A solo owner couple (no partner yet).
  static Couple solo() => make();

  /// A fully paired couple.
  static Couple paired({String partnerId = 'partner-uid'}) =>
      make(partnerId: partnerId);
}
