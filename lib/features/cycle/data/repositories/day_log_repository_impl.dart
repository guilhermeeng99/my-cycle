import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/cycle/data/datasources/day_log_remote_datasource.dart';
import 'package:mycycle/features/cycle/data/models/day_log_model.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/logging/domain/failures/log_failure.dart';

class DayLogRepositoryImpl implements DayLogRepository {
  DayLogRepositoryImpl({
    required DayLogRemoteDataSource remote,
    required Clock clock,
  })  : _remote = remote,
        _clock = clock;

  final DayLogRemoteDataSource _remote;
  final Clock _clock;

  @override
  Stream<DayLog?> watchDay(String coupleId, DateTime date) {
    return _remote.watchDay(coupleId, date).map((snap) {
      if (snap == null) return null;
      return DayLogModel.fromMap(
        snap.data,
        coupleId: coupleId,
        date: snap.date,
      );
    });
  }

  @override
  Stream<List<DayLog>> watchRange(
    String coupleId,
    DateTime from,
    DateTime to,
  ) {
    return _remote.watchRange(coupleId, from: from, to: to).map(
          (snaps) => snaps
              .map(
                (s) => DayLogModel.fromMap(
                  s.data,
                  coupleId: coupleId,
                  date: s.date,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<Result<DayLog>> upsertDayLog(DayLog log) async {
    if (log.isEmpty) {
      // Convention: empty logs are deleted, not written. Caller likely meant
      // to delete — surface a validation failure to make this explicit.
      return const Err<DayLog>(
        LogValidationFailure('log', 'Empty logs must be deleted, not upserted'),
      );
    }
    try {
      final model = DayLogModel(
        coupleId: log.coupleId,
        date: log.date,
        flow: log.flow,
        symptoms: log.symptoms,
        mood: log.mood,
        ownerNote: log.ownerNote,
        partnerNote: log.partnerNote,
        createdAt: log.createdAt,
        updatedAt: log.updatedAt,
      );
      await _remote.upsertDayLog(
        coupleId: log.coupleId,
        date: log.date,
        data: model.toMap(),
      );
      return Ok<DayLog>(model);
    } on FirebaseException catch (e) {
      return Err<DayLog>(LogStorageFailure(e.code, e.message ?? ''));
    } on Object catch (e) {
      return Err<DayLog>(UnknownLogFailure(e));
    }
  }

  @override
  Future<Result<void>> savePartnerNote({
    required String coupleId,
    required DateTime date,
    required String? note,
  }) async {
    if ((note?.length ?? 0) > 500) {
      return const Err<void>(
        LogValidationFailure('partnerNote', 'Note exceeds 500 characters'),
      );
    }
    try {
      await _remote.savePartnerNote(
        coupleId: coupleId,
        date: date,
        note: note,
        now: _clock.now(),
      );
      return const Ok<void>(null);
    } on FirebaseException catch (e) {
      return Err<void>(LogStorageFailure(e.code, e.message ?? ''));
    } on Object catch (e) {
      return Err<void>(UnknownLogFailure(e));
    }
  }

  @override
  Future<Result<void>> deleteDayLog(String coupleId, DateTime date) async {
    try {
      await _remote.deleteDayLog(coupleId: coupleId, date: date);
      return const Ok<void>(null);
    } on FirebaseException catch (e) {
      return Err<void>(LogStorageFailure(e.code, e.message ?? ''));
    } on Object catch (e) {
      return Err<void>(UnknownLogFailure(e));
    }
  }
}
