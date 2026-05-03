import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/features/auth/data/models/user_model.dart';
import 'package:mycycle/features/cycle/data/models/cycle_model.dart';
import 'package:mycycle/features/pairing/data/models/couple_model.dart';

/// JSON serializers used by the Hive document cache. Kept separate from
/// the Firestore-aware `*Model` classes because the on-disk representation
/// uses millis-since-epoch instead of `Timestamp`.
abstract final class CacheSerializers {
  // ─── User ─────────────────────────────────────────────────────────────

  static Object userToJson(User user) {
    return <String, dynamic>{
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'coupleId': user.coupleId,
      'role': user.role?.name,
      'language': user.language.name,
      'biometricEnabled': user.biometricEnabled,
      'notificationsEnabled': user.notificationsEnabled,
      'createdAt': user.createdAt.millisecondsSinceEpoch,
      'updatedAt': user.updatedAt.millisecondsSinceEpoch,
    };
  }

  static User userFromJson(Object json) =>
      UserModel.fromCacheJson(json as Map<String, dynamic>);

  // ─── Couple ───────────────────────────────────────────────────────────

  static Object coupleToJson(Couple couple) {
    return <String, dynamic>{
      'id': couple.id,
      'ownerId': couple.ownerId,
      'partnerId': couple.partnerId,
      'inviteCode': couple.inviteCode,
      'inviteExpiresAt': couple.inviteExpiresAt?.millisecondsSinceEpoch,
      'defaultCycleLength': couple.defaultCycleLength,
      'defaultLutealLength': couple.defaultLutealLength,
      'createdAt': couple.createdAt.millisecondsSinceEpoch,
      'updatedAt': couple.updatedAt.millisecondsSinceEpoch,
    };
  }

  static Couple coupleFromJson(Object json) =>
      CoupleModel.fromCacheJson(json as Map<String, dynamic>);

  // ─── Cycles list ──────────────────────────────────────────────────────

  static Object cyclesListToJson(List<Cycle> cycles) =>
      cycles.map(_cycleToJsonMap).toList();

  static List<Cycle> cyclesListFromJson(Object json) {
    final raw = json as List<dynamic>;
    return raw
        .cast<Map<dynamic, dynamic>>()
        .map((m) => CycleModel.fromCacheJson(m.cast<String, dynamic>()))
        .toList();
  }

  static Map<String, dynamic> _cycleToJsonMap(Cycle c) {
    return <String, dynamic>{
      'id': c.id,
      'coupleId': c.coupleId,
      'startDate': c.startDate.millisecondsSinceEpoch,
      'periodEndDate': c.periodEndDate?.millisecondsSinceEpoch,
      'totalLengthDays': c.totalLengthDays,
      'predictedNextStart': c.predictedNextStart?.millisecondsSinceEpoch,
      'predictedNextStartRangeEnd':
          c.predictedNextStartRangeEnd?.millisecondsSinceEpoch,
      'predictedOvulation': c.predictedOvulation?.millisecondsSinceEpoch,
      'predictionConfidence': c.predictionConfidence?.name,
      'createdAt': c.createdAt.millisecondsSinceEpoch,
      'updatedAt': c.updatedAt.millisecondsSinceEpoch,
    };
  }
}
