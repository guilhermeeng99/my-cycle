import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/utils/dates.dart';
import 'package:mycycle/features/cycle/data/datasources/cycle_remote_datasource.dart';
import 'package:mycycle/features/cycle/data/repositories/cycle_repository_impl.dart';

import '../../../../harness/mocks.dart';

void main() {
  late MockCycleRemoteDataSource remote;
  late MockClock clock;
  late CycleRepositoryImpl repository;

  setUp(() {
    remote = MockCycleRemoteDataSource();
    clock = MockClock();
    when(clock.now).thenReturn(DateTime.utc(2026, 5, 3));
    repository = CycleRepositoryImpl(remote: remote, clock: clock);
  });

  CycleDocSnapshot snapshot({
    String id = 'cycle-1',
    String startDate = '2026-04-19',
    String? periodEndDate,
    int? totalLengthDays,
    String? predictionConfidence,
  }) {
    return CycleDocSnapshot(
      id: id,
      data: <String, dynamic>{
        'startDate': startDate,
        'periodEndDate': periodEndDate,
        'totalLengthDays': totalLengthDays,
        'predictedNextStart': null,
        'predictedNextStartRangeEnd': null,
        'predictedOvulation': null,
        'predictionConfidence': predictionConfidence,
      },
    );
  }

  group('watchCurrentCycle', () {
    test('maps a snapshot to a Cycle with correct dates', () async {
      when(() => remote.watchCurrentCycle('couple-1')).thenAnswer(
        (_) => Stream<CycleDocSnapshot?>.value(snapshot()),
      );

      final cycle = await repository.watchCurrentCycle('couple-1').first;

      expect(cycle, isNotNull);
      expect(cycle!.id, 'cycle-1');
      expect(cycle.coupleId, 'couple-1');
      expect(cycle.startDate, parseIsoDate('2026-04-19'));
      expect(cycle.totalLengthDays, isNull);
    });

    test('emits null when the datasource has no current cycle', () async {
      when(() => remote.watchCurrentCycle('couple-1')).thenAnswer(
        (_) => Stream<CycleDocSnapshot?>.value(null),
      );

      final cycle = await repository.watchCurrentCycle('couple-1').first;

      expect(cycle, isNull);
    });
  });

  group('watchRecentCycles', () {
    test('maps multiple snapshots and preserves order', () async {
      when(() => remote.watchRecentCycles('couple-1', limit: 12)).thenAnswer(
        (_) => Stream<List<CycleDocSnapshot>>.value(<CycleDocSnapshot>[
          snapshot(id: 'c2'),
          snapshot(id: 'c1', startDate: '2026-03-22', totalLengthDays: 28),
        ]),
      );

      final cycles = await repository.watchRecentCycles('couple-1').first;

      expect(cycles, hasLength(2));
      expect(cycles[0].id, 'c2');
      expect(cycles[0].totalLengthDays, isNull);
      expect(cycles[1].id, 'c1');
      expect(cycles[1].totalLengthDays, 28);
    });

    test('parses prediction-confidence enum', () async {
      when(() => remote.watchRecentCycles('couple-1', limit: 12)).thenAnswer(
        (_) => Stream<List<CycleDocSnapshot>>.value(<CycleDocSnapshot>[
          snapshot(predictionConfidence: 'high'),
        ]),
      );

      final cycles = await repository.watchRecentCycles('couple-1').first;

      expect(cycles.single.predictionConfidence, ConfidenceLevel.high);
    });
  });
}
