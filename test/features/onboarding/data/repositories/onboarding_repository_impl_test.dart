import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/errors/result.dart';
import 'package:mycycle/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:mycycle/features/onboarding/domain/failures/onboarding_failure.dart';

import '../../../../harness/factories/user_factory.dart';
import '../../../../harness/mocks.dart';

class _FakeFirestore extends Fake implements FirebaseFirestore {}

void main() {
  late _FakeFirestore firestore;
  late MockClock clock;
  late OnboardingRepositoryImpl repository;

  setUp(() {
    firestore = _FakeFirestore();
    clock = MockClock();
    when(clock.now).thenReturn(defaultTestNow);
    repository = OnboardingRepositoryImpl(
      firestore: firestore,
      clock: clock,
    );
  });

  group('completeOwnerOnboarding — validation', () {
    test('rejects future lastPeriodStart with OnboardingValidationFailure',
        () async {
      final result = await repository.completeOwnerOnboarding(
        userId: 'uid-1',
        name: 'Marina',
        email: 'marina@example.com',
        lastPeriodStart: defaultTestNow.add(const Duration(days: 1)),
        defaultCycleLength: 28,
        notificationsEnabled: true,
        language: AppLanguage.ptBr,
      );

      expect(result, isA<Err<void>>());
      final failure =
          (result as Err<void>).error as OnboardingValidationFailure;
      expect(failure.field, 'lastPeriodStart');
    });

    test('rejects cycle length below 21', () async {
      final result = await repository.completeOwnerOnboarding(
        userId: 'uid-1',
        name: 'Marina',
        email: 'marina@example.com',
        lastPeriodStart: defaultTestNow.subtract(const Duration(days: 14)),
        defaultCycleLength: 20,
        notificationsEnabled: true,
        language: AppLanguage.ptBr,
      );

      expect(result, isA<Err<void>>());
      final failure =
          (result as Err<void>).error as OnboardingValidationFailure;
      expect(failure.field, 'defaultCycleLength');
    });

    test('rejects cycle length above 45', () async {
      final result = await repository.completeOwnerOnboarding(
        userId: 'uid-1',
        name: 'Marina',
        email: 'marina@example.com',
        lastPeriodStart: defaultTestNow.subtract(const Duration(days: 14)),
        defaultCycleLength: 46,
        notificationsEnabled: true,
        language: AppLanguage.ptBr,
      );

      expect(result, isA<Err<void>>());
      final failure =
          (result as Err<void>).error as OnboardingValidationFailure;
      expect(failure.field, 'defaultCycleLength');
    });

    test('accepts boundary values 21 and 45 (validation passes)', () async {
      // We can't easily mock the runTransaction call without a fake Firestore,
      // so we expect the call to fail at the Firestore call (not validation).
      // Both 21 and 45 should make it past validation.
      final r21 = await repository.completeOwnerOnboarding(
        userId: 'uid-1',
        name: 'Marina',
        email: 'marina@example.com',
        lastPeriodStart: defaultTestNow.subtract(const Duration(days: 14)),
        defaultCycleLength: 21,
        notificationsEnabled: true,
        language: AppLanguage.ptBr,
      );
      // Whatever the failure, it must NOT be a validation failure on
      // defaultCycleLength.
      if (r21 is Err<void>) {
        expect(
          r21.error is OnboardingValidationFailure &&
              (r21.error as OnboardingValidationFailure).field ==
                  'defaultCycleLength',
          isFalse,
        );
      }

      final r45 = await repository.completeOwnerOnboarding(
        userId: 'uid-1',
        name: 'Marina',
        email: 'marina@example.com',
        lastPeriodStart: defaultTestNow.subtract(const Duration(days: 14)),
        defaultCycleLength: 45,
        notificationsEnabled: true,
        language: AppLanguage.ptBr,
      );
      if (r45 is Err<void>) {
        expect(
          r45.error is OnboardingValidationFailure &&
              (r45.error as OnboardingValidationFailure).field ==
                  'defaultCycleLength',
          isFalse,
        );
      }
    });
  });
}
