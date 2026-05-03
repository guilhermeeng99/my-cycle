import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/day_log.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/day_log_repository.dart';
import 'package:mycycle/features/logging/domain/failures/log_failure.dart';
import 'package:mycycle/features/logging/domain/usecases/save_day_log.dart';

import '../../../../harness/factories/cycle_factory.dart';
import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

class _MockCycleRepo extends Mock implements CycleRepository {}

class _MockDayLogRepo extends Mock implements DayLogRepository {}

class _DayLogFake extends Fake implements DayLog {}

void main() {
  late _MockCycleRepo cycleRepo;
  late _MockDayLogRepo dayLogRepo;
  late MockClock clock;
  late SaveDayLog useCase;

  setUpAll(() {
    registerFallbackValue(_DayLogFake());
  });

  setUp(() {
    cycleRepo = _MockCycleRepo();
    dayLogRepo = _MockDayLogRepo();
    clock = MockClock();
    when(clock.now).thenReturn(defaultTestNow);
    useCase = SaveDayLog(
      cycleRepository: cycleRepo,
      dayLogRepository: dayLogRepo,
      clock: clock,
    );
  });

  SaveDayLogParams baseParams({
    FlowLevel? flow,
    Set<SymptomType> symptoms = const <SymptomType>{},
    MoodType? mood,
    String? ownerNote,
    bool markPeriodStarted = false,
    bool markPeriodEnded = false,
    String? currentCycleId,
  }) {
    return SaveDayLogParams(
      coupleId: 'couple-1',
      currentCycleId: currentCycleId,
      date: defaultTestNow,
      flow: flow,
      symptoms: symptoms,
      mood: mood,
      ownerNote: ownerNote,
      markPeriodStarted: markPeriodStarted,
      markPeriodEnded: markPeriodEnded,
    );
  }

  group('validation', () {
    test('rejects ownerNote longer than 500 chars', () async {
      final result = await useCase(
        baseParams(ownerNote: 'x' * 501, flow: FlowLevel.light),
      );
      expect(result, isA<Err<void>>());
      final err = (result as Err<void>).error as LogValidationFailure;
      expect(err.field, 'ownerNote');
    });
  });

  group('day log persistence', () {
    test('deletes the day log when nothing was selected', () async {
      when(() => dayLogRepo.deleteDayLog(any(), any()))
          .thenAnswer((_) async => const Ok<void>(null));

      final result = await useCase(baseParams());

      expect(result, isA<Ok<void>>());
      verify(() => dayLogRepo.deleteDayLog('couple-1', defaultTestNow))
          .called(1);
      verifyNever(() => dayLogRepo.upsertDayLog(any()));
    });

    test('upserts the day log when at least one field is set', () async {
      when(() => dayLogRepo.upsertDayLog(any())).thenAnswer((invocation) async {
        return Ok<DayLog>(invocation.positionalArguments.first as DayLog);
      });

      final result = await useCase(
        baseParams(
          flow: FlowLevel.medium,
          symptoms: {SymptomType.cramps, SymptomType.fatigue},
          mood: MoodType.irritable,
          ownerNote: 'tough day',
        ),
      );

      expect(result, isA<Ok<void>>());
      final captured = verify(
        () => dayLogRepo.upsertDayLog(captureAny()),
      ).captured.single as DayLog;
      expect(captured.flow, FlowLevel.medium);
      expect(captured.symptoms, {SymptomType.cramps, SymptomType.fatigue});
      expect(captured.mood, MoodType.irritable);
      expect(captured.ownerNote, 'tough day');
    });

    test('trims an ownerNote that is just whitespace to null', () async {
      when(() => dayLogRepo.upsertDayLog(any())).thenAnswer((invocation) async {
        return Ok<DayLog>(invocation.positionalArguments.first as DayLog);
      });

      // Note is whitespace, but flow is set → log is non-empty.
      await useCase(
        baseParams(flow: FlowLevel.light, ownerNote: '   '),
      );

      final captured = verify(
        () => dayLogRepo.upsertDayLog(captureAny()),
      ).captured.single as DayLog;
      expect(captured.ownerNote, isNull);
    });
  });

  group('cycle markers', () {
    test('startNewCycle is called when markPeriodStarted is true', () async {
      when(
        () => cycleRepo.startNewCycle(
          coupleId: any(named: 'coupleId'),
          startDate: any(named: 'startDate'),
        ),
      ).thenAnswer(
        (_) async => Ok<Cycle>(CycleFactory.firstEver()),
      );
      when(() => dayLogRepo.upsertDayLog(any())).thenAnswer((invocation) async {
        return Ok<DayLog>(invocation.positionalArguments.first as DayLog);
      });

      final result = await useCase(
        baseParams(flow: FlowLevel.medium, markPeriodStarted: true),
      );

      expect(result, isA<Ok<void>>());
      verify(
        () => cycleRepo.startNewCycle(
          coupleId: 'couple-1',
          startDate: defaultTestNow,
        ),
      ).called(1);
    });

    test('setPeriodEnd is called when markPeriodEnded + currentCycleId',
        () async {
      when(
        () => cycleRepo.setPeriodEnd(
          coupleId: any(named: 'coupleId'),
          cycleId: any(named: 'cycleId'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer(
        (_) async => Ok<Cycle>(CycleFactory.firstEver()),
      );
      when(() => dayLogRepo.deleteDayLog(any(), any()))
          .thenAnswer((_) async => const Ok<void>(null));

      final result = await useCase(
        baseParams(
          markPeriodEnded: true,
          currentCycleId: 'cycle-1',
        ),
      );

      expect(result, isA<Ok<void>>());
      verify(
        () => cycleRepo.setPeriodEnd(
          coupleId: 'couple-1',
          cycleId: 'cycle-1',
          endDate: defaultTestNow,
        ),
      ).called(1);
    });

    test('setPeriodEnd is skipped when currentCycleId is null', () async {
      when(() => dayLogRepo.deleteDayLog(any(), any()))
          .thenAnswer((_) async => const Ok<void>(null));

      final result = await useCase(baseParams(markPeriodEnded: true));

      expect(result, isA<Ok<void>>());
      verifyNever(
        () => cycleRepo.setPeriodEnd(
          coupleId: any(named: 'coupleId'),
          cycleId: any(named: 'cycleId'),
          endDate: any(named: 'endDate'),
        ),
      );
    });

    test('returns Err when startNewCycle fails (does not save day log)',
        () async {
      when(
        () => cycleRepo.startNewCycle(
          coupleId: any(named: 'coupleId'),
          startDate: any(named: 'startDate'),
        ),
      ).thenAnswer(
        (_) async => const Err<Cycle>(LogNetworkFailure()),
      );

      final result = await useCase(
        baseParams(flow: FlowLevel.medium, markPeriodStarted: true),
      );

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).error, isA<LogNetworkFailure>());
      verifyNever(() => dayLogRepo.upsertDayLog(any()));
    });
  });

  // touch user factory to keep import happy
  test('user factory smoke', () {
    expect(UserFactory.unpaired().id, isNotEmpty);
  });
}
