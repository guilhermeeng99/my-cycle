import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/hive/cache_serializers.dart';
import 'package:mycycle/core/hive/hive_doc_cache.dart';
import 'package:mycycle/features/cycle/data/datasources/cycle_remote_datasource.dart';
import 'package:mycycle/features/cycle/data/repositories/cycle_repository_impl.dart';

import '../../../../harness/factories/cycle_factory.dart';
import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

CycleDocSnapshot _snapshot({
  required String id,
  String startDate = '2026-04-19',
  int? totalLengthDays,
}) {
  return CycleDocSnapshot(
    id: id,
    data: <String, dynamic>{
      'startDate': startDate,
      'periodEndDate': null,
      'totalLengthDays': totalLengthDays,
      'predictedNextStart': null,
      'predictedNextStartRangeEnd': null,
      'predictedOvulation': null,
      'predictionConfidence': null,
    },
  );
}

void main() {
  late Box<String> box;
  late HiveDocCache<List<Cycle>> cache;
  late MockCycleRemoteDataSource remote;
  late MockClock clock;
  late CycleRepositoryImpl repository;

  setUpAll(() {
    Hive.init(Directory.systemTemp.createTempSync('hive-cycle-cache-').path);
  });

  setUp(() async {
    box = await Hive.openBox<String>(
      'cycles-${DateTime.now().microsecondsSinceEpoch}',
    );
    cache = HiveDocCache<List<Cycle>>(
      box: box,
      toJson: CacheSerializers.cyclesListToJson,
      fromJson: CacheSerializers.cyclesListFromJson,
    );
    remote = MockCycleRemoteDataSource();
    clock = MockClock();
    when(clock.now).thenReturn(defaultTestNow);
    repository = CycleRepositoryImpl(
      remote: remote,
      clock: clock,
      recentCyclesCache: cache,
    );
  });

  tearDown(() async {
    await box.close();
  });

  test('emits the cached list synchronously before the remote arrives',
      () async {
    final seeded = <Cycle>[
      CycleFactory.make(id: 'seeded', totalLengthDays: 28),
    ];
    await cache.write('couple-1:12', seeded);

    final remoteController = StreamController<List<CycleDocSnapshot>>();
    when(
      () => remote.watchRecentCycles(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) => remoteController.stream);

    final emitted = <int>[];
    final sub = repository
        .watchRecentCycles('couple-1')
        .listen((cycles) => emitted.add(cycles.length));

    await pumpEventQueue();
    expect(emitted, <int>[1], reason: 'cached first emission');

    remoteController.add(<CycleDocSnapshot>[
      _snapshot(id: 'a', totalLengthDays: 30),
      _snapshot(id: 'b', totalLengthDays: 27),
    ]);
    await pumpEventQueue();
    expect(emitted, <int>[1, 2]);

    await sub.cancel();
    await remoteController.close();
  });

  test('persists each remote emission back into the box', () async {
    final controller = StreamController<List<CycleDocSnapshot>>();
    when(
      () => remote.watchRecentCycles(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) => controller.stream);

    final sub = repository.watchRecentCycles('couple-1').listen((_) {});
    controller.add(<CycleDocSnapshot>[_snapshot(id: 'a', totalLengthDays: 30)]);
    await pumpEventQueue();

    final cached = cache.read('couple-1:12');
    expect(cached, isNotNull);
    expect(cached!.single.id, 'a');

    await sub.cancel();
    await controller.close();
  });

  test('different limits use distinct cache keys', () async {
    await cache.write('couple-1:5', <Cycle>[CycleFactory.make(id: 'small')]);
    await cache.write('couple-1:12', <Cycle>[
      CycleFactory.make(id: 'big-1'),
      CycleFactory.make(id: 'big-2'),
    ]);

    when(
      () => remote.watchRecentCycles(any(), limit: any(named: 'limit')),
    ).thenAnswer((_) => const Stream<List<CycleDocSnapshot>>.empty());

    final small = await repository
        .watchRecentCycles('couple-1', limit: 5)
        .first;
    final big = await repository.watchRecentCycles('couple-1').first;

    expect(small, hasLength(1));
    expect(big, hasLength(2));
  });
}
