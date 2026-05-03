import 'package:cloud_firestore/cloud_firestore.dart';

class CycleDocSnapshot {
  const CycleDocSnapshot({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
}

abstract class CycleRemoteDataSource {
  /// Most recent cycle (by `startDate` desc) where `totalLengthDays == null`.
  Stream<CycleDocSnapshot?> watchCurrentCycle(String coupleId);

  /// Recent cycles ordered by `startDate` descending, capped at [limit].
  Stream<List<CycleDocSnapshot>> watchRecentCycles(
    String coupleId, {
    required int limit,
  });

  /// Returns the open cycle (if any), or null. One-shot read.
  Future<CycleDocSnapshot?> fetchCurrentCycle(String coupleId);

  /// Closes [cycleId] in [coupleId] by writing `totalLengthDays` and bumping
  /// `updatedAt`.
  Future<void> closeCycle({
    required String coupleId,
    required String cycleId,
    required int totalLengthDays,
    required DateTime updatedAt,
  });

  /// Creates a new cycle doc. Returns the generated id.
  Future<String> createCycle({
    required String coupleId,
    required Map<String, dynamic> data,
  });

  /// Updates [cycleId]'s `periodEndDate` and bumps `updatedAt`.
  Future<void> setPeriodEnd({
    required String coupleId,
    required String cycleId,
    required String periodEndDateIso,
    required DateTime updatedAt,
  });

  /// Reads a single cycle. Returns null if not found.
  Future<CycleDocSnapshot?> fetchCycleById({
    required String coupleId,
    required String cycleId,
  });
}

class CycleRemoteDataSourceImpl implements CycleRemoteDataSource {
  CycleRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _cyclesRef(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('cycles');
  }

  @override
  Stream<CycleDocSnapshot?> watchCurrentCycle(String coupleId) {
    return _cyclesRef(coupleId)
        .where('totalLengthDays', isNull: true)
        .orderBy('startDate', descending: true)
        .limit(1)
        .snapshots()
        .map((qs) {
      if (qs.docs.isEmpty) return null;
      final doc = qs.docs.first;
      return CycleDocSnapshot(id: doc.id, data: doc.data());
    });
  }

  @override
  Stream<List<CycleDocSnapshot>> watchRecentCycles(
    String coupleId, {
    required int limit,
  }) {
    return _cyclesRef(coupleId)
        .orderBy('startDate', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (qs) => qs.docs
              .map(
                (doc) => CycleDocSnapshot(id: doc.id, data: doc.data()),
              )
              .toList(),
        );
  }

  @override
  Future<CycleDocSnapshot?> fetchCurrentCycle(String coupleId) async {
    final qs = await _cyclesRef(coupleId)
        .where('totalLengthDays', isNull: true)
        .orderBy('startDate', descending: true)
        .limit(1)
        .get();
    if (qs.docs.isEmpty) return null;
    final doc = qs.docs.first;
    return CycleDocSnapshot(id: doc.id, data: doc.data());
  }

  @override
  Future<void> closeCycle({
    required String coupleId,
    required String cycleId,
    required int totalLengthDays,
    required DateTime updatedAt,
  }) async {
    await _cyclesRef(coupleId).doc(cycleId).update(<String, dynamic>{
      'totalLengthDays': totalLengthDays,
      'updatedAt': Timestamp.fromDate(updatedAt),
    });
  }

  @override
  Future<String> createCycle({
    required String coupleId,
    required Map<String, dynamic> data,
  }) async {
    final ref = _cyclesRef(coupleId).doc();
    await ref.set(data);
    return ref.id;
  }

  @override
  Future<void> setPeriodEnd({
    required String coupleId,
    required String cycleId,
    required String periodEndDateIso,
    required DateTime updatedAt,
  }) async {
    await _cyclesRef(coupleId).doc(cycleId).update(<String, dynamic>{
      'periodEndDate': periodEndDateIso,
      'updatedAt': Timestamp.fromDate(updatedAt),
    });
  }

  @override
  Future<CycleDocSnapshot?> fetchCycleById({
    required String coupleId,
    required String cycleId,
  }) async {
    final snap = await _cyclesRef(coupleId).doc(cycleId).get();
    final data = snap.data();
    if (data == null) return null;
    return CycleDocSnapshot(id: snap.id, data: data);
  }
}
