import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/insights/presentation/cubits/insights_cubit.dart';
import 'package:mycycle/features/pairing/domain/repositories/couple_repository.dart';

import '../../../../harness/factories/couple_factory.dart';
import '../../../../harness/factories/cycle_factory.dart';
import '../../../../harness/factories/user_factory.dart';

class _MockCycleRepository extends Mock implements CycleRepository {}

class _MockCoupleRepository extends Mock implements CoupleRepository {}

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

InsightsCubit _build({
  required _MockCycleRepository cycle,
  required _MockCoupleRepository couple,
  required Stream<Couple?> coupleStream,
  required Stream<List<Cycle>> cyclesStream,
}) {
  when(() => couple.watchCouple(any())).thenAnswer((_) => coupleStream);
  when(
    () => cycle.watchRecentCycles(any(), limit: any(named: 'limit')),
  ).thenAnswer((_) => cyclesStream);
  return InsightsCubit(
    coupleId: 'couple-1',
    cycleRepository: cycle,
    coupleRepository: couple,
    clock: _FixedClock(defaultTestNow),
  );
}

Cycle _closed({
  required String id,
  required DateTime startDate,
  required int length,
  int? periodLength,
}) {
  return CycleFactory.make(
    id: id,
    startDate: startDate,
    totalLengthDays: length,
    periodEndDate: periodLength == null
        ? null
        : startDate.add(Duration(days: periodLength - 1)),
  );
}

void main() {
  late _MockCycleRepository cycle;
  late _MockCoupleRepository couple;

  setUp(() {
    cycle = _MockCycleRepository();
    couple = _MockCoupleRepository();
  });

  test('initial state is Loading', () {
    final cubit = _build(
      cycle: cycle,
      couple: couple,
      coupleStream: const Stream<Couple?>.empty(),
      cyclesStream: const Stream<List<Cycle>>.empty(),
    );

    expect(cubit.state, isA<InsightsLoading>());
  });

  test('emits Empty when no closed cycles and no current cycle', () async {
    final cubit = _build(
      cycle: cycle,
      couple: couple,
      coupleStream: Stream<Couple?>.value(CoupleFactory.paired()),
      cyclesStream: Stream<List<Cycle>>.value(<Cycle>[]),
    );

    await expectLater(
      cubit.stream,
      emitsThrough(isA<InsightsEmpty>()),
    );
  });

  test('Loaded.regularity is null with fewer than 3 closed cycles', () async {
    final cubit = _build(
      cycle: cycle,
      couple: couple,
      coupleStream: Stream<Couple?>.value(CoupleFactory.paired()),
      cyclesStream: Stream<List<Cycle>>.value(<Cycle>[
        _closed(
          id: 'c1',
          startDate: defaultTestNow.subtract(const Duration(days: 28)),
          length: 28,
        ),
        _closed(
          id: 'c2',
          startDate: defaultTestNow.subtract(const Duration(days: 56)),
          length: 27,
        ),
      ]),
    );

    final state = await cubit.stream.firstWhere((s) => s is InsightsLoaded)
        as InsightsLoaded;
    expect(state.regularity, isNull);
    expect(state.totalTrackedCycles, 2);
  });

  test('regularity high when std-dev ≤ 2 days across ≥ 3 cycles', () async {
    final cubit = _build(
      cycle: cycle,
      couple: couple,
      coupleStream: Stream<Couple?>.value(CoupleFactory.paired()),
      cyclesStream: Stream<List<Cycle>>.value(<Cycle>[
        _closed(
          id: 'c1',
          startDate: defaultTestNow.subtract(const Duration(days: 28)),
          length: 28,
        ),
        _closed(
          id: 'c2',
          startDate: defaultTestNow.subtract(const Duration(days: 56)),
          length: 29,
        ),
        _closed(
          id: 'c3',
          startDate: defaultTestNow.subtract(const Duration(days: 84)),
          length: 27,
        ),
      ]),
    );

    final state = await cubit.stream.firstWhere((s) => s is InsightsLoaded)
        as InsightsLoaded;
    expect(state.regularity, Regularity.high);
  });

  test('regularity low when std-dev > 4 days', () async {
    final cubit = _build(
      cycle: cycle,
      couple: couple,
      coupleStream: Stream<Couple?>.value(CoupleFactory.paired()),
      cyclesStream: Stream<List<Cycle>>.value(<Cycle>[
        _closed(
          id: 'c1',
          startDate: defaultTestNow.subtract(const Duration(days: 21)),
          length: 21,
        ),
        _closed(
          id: 'c2',
          startDate: defaultTestNow.subtract(const Duration(days: 56)),
          length: 35,
        ),
        _closed(
          id: 'c3',
          startDate: defaultTestNow.subtract(const Duration(days: 84)),
          length: 28,
        ),
      ]),
    );

    final state = await cubit.stream.firstWhere((s) => s is InsightsLoaded)
        as InsightsLoaded;
    expect(state.regularity, Regularity.low);
  });

  test('averagePeriodDays is null when no closed cycle has periodEndDate',
      () async {
    final cubit = _build(
      cycle: cycle,
      couple: couple,
      coupleStream: Stream<Couple?>.value(CoupleFactory.paired()),
      cyclesStream: Stream<List<Cycle>>.value(<Cycle>[
        _closed(
          id: 'c1',
          startDate: defaultTestNow.subtract(const Duration(days: 28)),
          length: 28,
        ),
      ]),
    );

    final state = await cubit.stream.firstWhere((s) => s is InsightsLoaded)
        as InsightsLoaded;
    expect(state.averagePeriodDays, isNull);
    expect(state.averageCycleDays, 28);
  });

  test('prediction is computed when current cycle is present', () async {
    final cubit = _build(
      cycle: cycle,
      couple: couple,
      coupleStream: Stream<Couple?>.value(CoupleFactory.paired()),
      cyclesStream: Stream<List<Cycle>>.value(<Cycle>[
        CycleFactory.make(
          id: 'current',
          startDate: defaultTestNow.subtract(const Duration(days: 10)),
        ),
      ]),
    );

    final state = await cubit.stream.firstWhere((s) => s is InsightsLoaded)
        as InsightsLoaded;
    expect(state.prediction, isNotNull);
  });
}
