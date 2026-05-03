import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/couple.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/features/cycle/domain/entities/cycle_phase.dart';
import 'package:mycycle/features/today/presentation/cubits/today_cubit.dart';

import '../../../../harness/factories/couple_factory.dart';
import '../../../../harness/factories/cycle_factory.dart';
import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockCycleRepository cycleRepo;
  late MockCoupleRepository coupleRepo;
  late MockClock clock;

  final today = DateTime.utc(2026, 5, 3);

  setUp(() {
    cycleRepo = MockCycleRepository();
    coupleRepo = MockCoupleRepository();
    clock = MockClock();
    when(clock.now).thenReturn(today);
  });

  TodayCubit buildCubit({
    required User user,
    Couple? couple,
    Cycle? currentCycle,
    List<Cycle> recent = const <Cycle>[],
  }) {
    final coupleId = user.coupleId ?? 'couple-1';
    when(() => coupleRepo.watchCouple(coupleId))
        .thenAnswer((_) => Stream<Couple?>.value(couple));
    when(() => cycleRepo.watchCurrentCycle(coupleId))
        .thenAnswer((_) => Stream<Cycle?>.value(currentCycle));
    when(() => cycleRepo.watchRecentCycles(coupleId))
        .thenAnswer((_) => Stream<List<Cycle>>.value(recent));
    return TodayCubit(
      user: user,
      cycleRepository: cycleRepo,
      coupleRepository: coupleRepo,
      clock: clock,
    );
  }

  test('emits TodayEmpty when the user has no coupleId', () async {
    final cubit = TodayCubit(
      user: UserFactory.unpaired(),
      cycleRepository: cycleRepo,
      coupleRepository: coupleRepo,
      clock: clock,
    );
    expect(cubit.state, isA<TodayEmpty>());
    await cubit.close();
  });

  test('emits TodayEmpty when the couple is loaded but no current cycle',
      () async {
    final cubit = buildCubit(
      user: UserFactory.owner(),
      couple: CoupleFactory.solo(),
      // no current cycle
    );
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<TodayEmpty>());
    await cubit.close();
  });

  test('emits TodayLoaded once couple + current cycle are available',
      () async {
    final cycleStart = DateTime.utc(2026, 4, 19);
    final cubit = buildCubit(
      user: UserFactory.owner(),
      couple: CoupleFactory.solo(),
      currentCycle: CycleFactory.make(id: 'current', startDate: cycleStart),
    );
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, isA<TodayLoaded>());
    final vm = (cubit.state as TodayLoaded).vm;
    expect(vm.dayN, 15); // today (May 3) - cycleStart (Apr 19) = 14 → day 15
    expect(vm.phase, anyOf(CyclePhase.menstrual, CyclePhase.ovulation));
    await cubit.close();
  });

  test('VM.cycleLengthEstimate stays within [21, 60]', () async {
    final cycleStart = DateTime.utc(2026, 4, 19);
    final cubit = buildCubit(
      user: UserFactory.owner(),
      couple: CoupleFactory.solo(),
      currentCycle: CycleFactory.make(id: 'current', startDate: cycleStart),
    );
    await Future<void>.delayed(Duration.zero);
    final vm = (cubit.state as TodayLoaded).vm;
    expect(vm.cycleLengthEstimate, inInclusiveRange(21, 60));
    await cubit.close();
  });
}
