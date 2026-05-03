import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/pairing/domain/entities/invite_code.dart';

abstract class CoupleRepository {
  Stream<Couple?> watchCouple(String coupleId);

  /// Generates a 24h invite code, writes it to the couple, returns it.
  /// Owner-only — security rules enforce.
  Future<Result<InviteCode>> generateInviteCode(String coupleId);

  /// Looks up the couple owning [code], verifies it's valid + not expired +
  /// the couple has no partner, then atomically links [partnerId] into it.
  Future<Result<Couple>> redeemInviteCode({
    required String partnerId,
    required String code,
  });

  /// Removes [userId] from [coupleId]. The partner sets `partnerId = null`
  /// on the couple (per rules) and clears their own user doc's `coupleId`.
  Future<Result<void>> leaveCouple({
    required String coupleId,
    required String userId,
  });

  /// Owner-only: deletes every cycle and day-log under [coupleId], then the
  /// couple doc itself. The partner's user doc keeps a stale `coupleId`
  /// until their next session reconciles it.
  Future<Result<void>> deleteCoupleData(String coupleId);
}
