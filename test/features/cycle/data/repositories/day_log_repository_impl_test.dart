import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/cycle/data/datasources/day_log_remote_datasource.dart';
import 'package:mycycle/features/cycle/data/repositories/day_log_repository_impl.dart';
import 'package:mycycle/features/logging/domain/failures/log_failure.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

class _MockDayLogRemoteDataSource extends Mock
    implements DayLogRemoteDataSource {}

void main() {
  late _MockDayLogRemoteDataSource remote;
  late MockClock clock;
  late DayLogRepositoryImpl repository;

  setUp(() {
    remote = _MockDayLogRemoteDataSource();
    clock = MockClock();
    when(clock.now).thenReturn(defaultTestNow);
    repository = DayLogRepositoryImpl(remote: remote, clock: clock);
  });

  DayLog logFor({
    FlowLevel? flow = FlowLevel.medium,
    Set<SymptomType> symptoms = const <SymptomType>{},
    MoodType? mood,
    String? ownerNote,
  }) {
    return DayLog(
      coupleId: 'couple-1',
      date: defaultTestNow,
      flow: flow,
      symptoms: symptoms,
      mood: mood,
      ownerNote: ownerNote,
      createdAt: defaultTestNow,
      updatedAt: defaultTestNow,
    );
  }

  group('upsertDayLog', () {
    test('rejects empty logs with LogValidationFailure', () async {
      final result = await repository.upsertDayLog(logFor(flow: null));
      expect(result, isA<Err<DayLog>>());
      final err = (result as Err<DayLog>).error as LogValidationFailure;
      expect(err.field, 'log');
    });

    test('writes through to the datasource for non-empty logs', () async {
      when(
        () => remote.upsertDayLog(
          coupleId: any(named: 'coupleId'),
          date: any(named: 'date'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.upsertDayLog(logFor());

      expect(result, isA<Ok<DayLog>>());
      verify(
        () => remote.upsertDayLog(
          coupleId: 'couple-1',
          date: defaultTestNow,
          data: any(named: 'data'),
        ),
      ).called(1);
    });
  });

  group('deleteDayLog', () {
    test('returns Ok on success', () async {
      when(
        () => remote.deleteDayLog(
          coupleId: any(named: 'coupleId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteDayLog('couple-1', defaultTestNow);

      expect(result, isA<Ok<void>>());
    });
  });
}
