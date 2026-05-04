import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mycycle/core/utils/dates.dart';

class DayLogDocSnapshot {
  const DayLogDocSnapshot({required this.date, required this.data});
  final DateTime date;
  final Map<String, dynamic> data;
}

abstract class DayLogRemoteDataSource {
  Stream<DayLogDocSnapshot?> watchDay(String coupleId, DateTime date);

  Stream<List<DayLogDocSnapshot>> watchRange(
    String coupleId, {
    required DateTime from,
    required DateTime to,
  });

  Future<void> upsertDayLog({
    required String coupleId,
    required DateTime date,
    required Map<String, dynamic> data,
  });

  /// Partner-only write path: only `partnerNote` + `updatedAt` (and
  /// `createdAt` if the doc is new). Avoids touching owner-only fields,
  /// which Firestore rules would reject.
  Future<void> savePartnerNote({
    required String coupleId,
    required DateTime date,
    required String? note,
    required DateTime now,
  });

  Future<void> deleteDayLog({
    required String coupleId,
    required DateTime date,
  });
}

class DayLogRemoteDataSourceImpl implements DayLogRemoteDataSource {
  DayLogRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _daysRef(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('days');
  }

  @override
  Stream<DayLogDocSnapshot?> watchDay(String coupleId, DateTime date) {
    final id = formatIsoDate(date);
    return _daysRef(coupleId).doc(id).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return DayLogDocSnapshot(date: date, data: data);
    });
  }

  @override
  Stream<List<DayLogDocSnapshot>> watchRange(
    String coupleId, {
    required DateTime from,
    required DateTime to,
  }) {
    final fromId = formatIsoDate(from);
    final toId = formatIsoDate(to);
    return _daysRef(coupleId)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: fromId)
        .where(FieldPath.documentId, isLessThanOrEqualTo: toId)
        .snapshots()
        .map(
          (qs) => qs.docs
              .map(
                (doc) => DayLogDocSnapshot(
                  date: parseIsoDate(doc.id),
                  data: doc.data(),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> upsertDayLog({
    required String coupleId,
    required DateTime date,
    required Map<String, dynamic> data,
  }) async {
    final id = formatIsoDate(date);
    await _daysRef(coupleId).doc(id).set(data);
  }

  @override
  Future<void> savePartnerNote({
    required String coupleId,
    required DateTime date,
    required String? note,
    required DateTime now,
  }) async {
    final id = formatIsoDate(date);
    final ref = _daysRef(coupleId).doc(id);
    final exists = (await ref.get()).exists;
    final ts = Timestamp.fromDate(now);
    final data = <String, dynamic>{
      'partnerNote': (note == null || note.trim().isEmpty) ? null : note.trim(),
      'updatedAt': ts,
      if (!exists) 'createdAt': ts,
    };
    await ref.set(data, SetOptions(merge: true));
  }

  @override
  Future<void> deleteDayLog({
    required String coupleId,
    required DateTime date,
  }) async {
    final id = formatIsoDate(date);
    await _daysRef(coupleId).doc(id).delete();
  }
}
