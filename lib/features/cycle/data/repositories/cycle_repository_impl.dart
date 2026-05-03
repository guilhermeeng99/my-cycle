import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/core/hive/hive_doc_cache.dart';
import 'package:mycycle/core/utils/dates.dart';
import 'package:mycycle/features/cycle/data/datasources/cycle_remote_datasource.dart';
import 'package:mycycle/features/cycle/data/models/cycle_model.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/logging/domain/failures/log_failure.dart';

class CycleRepositoryImpl implements CycleRepository {
  CycleRepositoryImpl({
    required CycleRemoteDataSource remote,
    required Clock clock,
    HiveDocCache<List<Cycle>>? recentCyclesCache,
  })  : _remote = remote,
        _clock = clock,
        _cache = recentCyclesCache;

  final CycleRemoteDataSource _remote;
  final Clock _clock;
  final HiveDocCache<List<Cycle>>? _cache;

  /// Cache key for `watchRecentCycles` is the `coupleId` plus the limit —
  /// different limits would otherwise overwrite each other.
  String _key(String coupleId, int limit) => '$coupleId:$limit';

  @override
  Stream<Cycle?> watchCurrentCycle(String coupleId) {
    return _remote.watchCurrentCycle(coupleId).map((snapshot) {
      if (snapshot == null) return null;
      return CycleModel.fromMap(
        snapshot.data,
        id: snapshot.id,
        coupleId: coupleId,
      );
    });
  }

  @override
  Stream<List<Cycle>> watchRecentCycles(
    String coupleId, {
    int limit = 12,
  }) {
    final remote = _remote
        .watchRecentCycles(coupleId, limit: limit)
        .map<List<Cycle>>(
          (snapshots) => snapshots
              .map(
                (s) =>
                    CycleModel.fromMap(s.data, id: s.id, coupleId: coupleId),
              )
              .toList(),
        );
    final cache = _cache;
    if (cache == null) return remote;
    // `merge` types as `Stream<T?>`; recent cycles never goes null
    // (Firestore returns an empty list when there are no docs), so we
    // strip the nullability for the consumer.
    return cache
        .merge(key: _key(coupleId, limit), remote: remote)
        .map((cycles) => cycles ?? const <Cycle>[]);
  }

  @override
  Future<Result<Cycle>> startNewCycle({
    required String coupleId,
    required DateTime startDate,
  }) async {
    try {
      final newStart = normalizeDate(startDate);
      final now = _clock.now();
      final nowTs = Timestamp.fromDate(now);

      // 1. Close any open cycle whose start is strictly before [newStart].
      final open = await _remote.fetchCurrentCycle(coupleId);
      if (open != null) {
        final oldStart = parseIsoDate(open.data['startDate'] as String);
        final length = daysBetween(oldStart, newStart);
        if (length > 0) {
          await _remote.closeCycle(
            coupleId: coupleId,
            cycleId: open.id,
            totalLengthDays: length,
            updatedAt: now,
          );
        }
      }

      // 2. Create the new cycle.
      final data = <String, dynamic>{
        'startDate': formatIsoDate(newStart),
        'periodEndDate': null,
        'totalLengthDays': null,
        'predictedNextStart': null,
        'predictedNextStartRangeEnd': null,
        'predictedOvulation': null,
        'predictionConfidence': null,
        'createdAt': nowTs,
        'updatedAt': nowTs,
      };
      final newId = await _remote.createCycle(coupleId: coupleId, data: data);

      return Ok<Cycle>(
        CycleModel(
          id: newId,
          coupleId: coupleId,
          startDate: newStart,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } on FirebaseException catch (e, stack) {
      debugPrint('startNewCycle failed: [${e.code}] ${e.message}\n$stack');
      return Err<Cycle>(LogStorageFailure(e.code, e.message ?? ''));
    } on Object catch (e, stack) {
      debugPrint('startNewCycle unexpected: $e\n$stack');
      return Err<Cycle>(UnknownLogFailure(e));
    }
  }

  @override
  Future<Result<Cycle>> setPeriodEnd({
    required String coupleId,
    required String cycleId,
    required DateTime endDate,
  }) async {
    try {
      final normalized = normalizeDate(endDate);
      final now = _clock.now();
      await _remote.setPeriodEnd(
        coupleId: coupleId,
        cycleId: cycleId,
        periodEndDateIso: formatIsoDate(normalized),
        updatedAt: now,
      );
      // Re-fetch to return the canonical state.
      final fresh = await _remote.fetchCycleById(
        coupleId: coupleId,
        cycleId: cycleId,
      );
      if (fresh == null) {
        return const Err<Cycle>(
          LogValidationFailure('cycleId', 'Cycle not found after update'),
        );
      }
      return Ok<Cycle>(
        CycleModel.fromMap(fresh.data, id: fresh.id, coupleId: coupleId),
      );
    } on FirebaseException catch (e, stack) {
      debugPrint('setPeriodEnd failed: [${e.code}] ${e.message}\n$stack');
      return Err<Cycle>(LogStorageFailure(e.code, e.message ?? ''));
    } on Object catch (e, stack) {
      debugPrint('setPeriodEnd unexpected: $e\n$stack');
      return Err<Cycle>(UnknownLogFailure(e));
    }
  }
}
