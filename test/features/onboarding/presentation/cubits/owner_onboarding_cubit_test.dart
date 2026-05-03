import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/onboarding/domain/failures/onboarding_failure.dart';
import 'package:mycycle/features/onboarding/presentation/cubits/owner_onboarding_cubit.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

void main() {
  late MockOnboardingRepository repository;

  setUp(() {
    repository = MockOnboardingRepository();
  });

  OwnerOnboardingCubit buildCubit() => OwnerOnboardingCubit(
        repository: repository,
        userId: 'uid-1',
        userName: 'Marina',
        userEmail: 'marina@example.com',
      );

  group('OwnerOnboardingCubit — step navigation', () {
    test('starts at the welcome step with default form data', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<OwnerOnboardingEditing>());
      final state = cubit.state as OwnerOnboardingEditing;
      expect(state.step, OnboardingStep.welcome);
      expect(state.data.lastPeriodStart, isNull);
      expect(state.data.defaultCycleLength, 28);
      expect(state.data.notificationsEnabled, isTrue);
    });

    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'next() advances welcome → lastPeriod → cycleLength → notifications',
      build: buildCubit,
      act: (cubit) {
        final lastPeriod = defaultTestNow.subtract(const Duration(days: 7));
        cubit
          ..next()
          ..setLastPeriodStart(lastPeriod)
          ..next()
          ..next();
      },
      verify: (cubit) {
        final state = cubit.state as OwnerOnboardingEditing;
        expect(state.step, OnboardingStep.notifications);
        expect(state.data.lastPeriodStart, isNotNull);
      },
    );

    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'next() on lastPeriod is a no-op without a date selected',
      build: buildCubit,
      act: (cubit) {
        cubit
          ..next() // welcome → lastPeriod
          ..next(); // attempt — should not advance
      },
      verify: (cubit) {
        final state = cubit.state as OwnerOnboardingEditing;
        expect(state.step, OnboardingStep.lastPeriod);
      },
    );

    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'back() walks the steps in reverse',
      build: buildCubit,
      act: (cubit) {
        final lastPeriod = defaultTestNow.subtract(const Duration(days: 7));
        cubit
          ..next()
          ..setLastPeriodStart(lastPeriod)
          ..next()
          ..back();
      },
      verify: (cubit) {
        final state = cubit.state as OwnerOnboardingEditing;
        expect(state.step, OnboardingStep.lastPeriod);
        expect(state.data.lastPeriodStart, isNotNull);
      },
    );

    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'back() on welcome is a no-op',
      build: buildCubit,
      act: (cubit) => cubit.back(),
      expect: () => <OwnerOnboardingState>[],
    );
  });

  group('OwnerOnboardingCubit — form mutation', () {
    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'setCycleLength clamps to the slider range and updates form data',
      build: buildCubit,
      act: (cubit) {
        cubit.setCycleLength(32);
      },
      verify: (cubit) {
        expect(cubit.state.data.defaultCycleLength, 32);
      },
    );

    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'setNotificationsEnabled flips the form flag',
      build: buildCubit,
      act: (cubit) {
        cubit.setNotificationsEnabled(enabled: false);
      },
      verify: (cubit) {
        expect(cubit.state.data.notificationsEnabled, isFalse);
      },
    );
  });

  group('OwnerOnboardingCubit — submit', () {
    setUpAll(() {
      registerFallbackValue(AppLanguage.ptBr);
    });

    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'submit emits Submitting → Done on Ok',
      setUp: () {
        when(
          () => repository.completeOwnerOnboarding(
            userId: any(named: 'userId'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            photoUrl: any(named: 'photoUrl'),
            lastPeriodStart: any(named: 'lastPeriodStart'),
            defaultCycleLength: any(named: 'defaultCycleLength'),
            notificationsEnabled: any(named: 'notificationsEnabled'),
            language: any(named: 'language'),
          ),
        ).thenAnswer((_) async => const Ok<void>(null));
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.setLastPeriodStart(
          defaultTestNow.subtract(const Duration(days: 7)),
        );
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state, isA<OwnerOnboardingDone>());
        verify(
          () => repository.completeOwnerOnboarding(
            userId: 'uid-1',
            name: 'Marina',
            email: 'marina@example.com',
            photoUrl: any(named: 'photoUrl'),
            lastPeriodStart: any(named: 'lastPeriodStart'),
            defaultCycleLength: 28,
            notificationsEnabled: true,
            language: AppLanguage.ptBr,
          ),
        ).called(1);
      },
    );

    blocTest<OwnerOnboardingCubit, OwnerOnboardingState>(
      'submit emits Submitting → Error on Err',
      setUp: () {
        when(
          () => repository.completeOwnerOnboarding(
            userId: any(named: 'userId'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            photoUrl: any(named: 'photoUrl'),
            lastPeriodStart: any(named: 'lastPeriodStart'),
            defaultCycleLength: any(named: 'defaultCycleLength'),
            notificationsEnabled: any(named: 'notificationsEnabled'),
            language: any(named: 'language'),
          ),
        ).thenAnswer(
          (_) async => const Err<void>(OnboardingNetworkFailure()),
        );
      },
      build: buildCubit,
      act: (cubit) async {
        cubit.setLastPeriodStart(
          defaultTestNow.subtract(const Duration(days: 7)),
        );
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state, isA<OwnerOnboardingError>());
        expect(
          (cubit.state as OwnerOnboardingError).failure,
          isA<OnboardingNetworkFailure>(),
        );
      },
    );

    test('submit is a no-op without a lastPeriodStart', () async {
      final cubit = buildCubit();
      await cubit.submit();
      expect(cubit.state, isA<OwnerOnboardingEditing>());
      verifyNever(
        () => repository.completeOwnerOnboarding(
          userId: any(named: 'userId'),
          name: any(named: 'name'),
          email: any(named: 'email'),
          photoUrl: any(named: 'photoUrl'),
          lastPeriodStart: any(named: 'lastPeriodStart'),
          defaultCycleLength: any(named: 'defaultCycleLength'),
          notificationsEnabled: any(named: 'notificationsEnabled'),
          language: any(named: 'language'),
        ),
      );
    });
  });
}
