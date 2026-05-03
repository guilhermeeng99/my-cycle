import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/notifications/notifications_coordinator.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';

import '../../harness/factories/cycle_factory.dart';
import '../../harness/factories/user_factory.dart';
import '../../harness/mocks.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockCycleRepository cycleRepo;
  late MockNotificationsRepository notifRepo;
  late MockClock clock;
  late NotificationsCoordinator coordinator;

  setUpAll(() {
    registerFallbackValue(AppLanguage.ptBr);
  });

  setUp(() {
    authRepo = MockAuthRepository();
    cycleRepo = MockCycleRepository();
    notifRepo = MockNotificationsRepository();
    clock = MockClock();

    when(clock.now).thenReturn(DateTime.utc(2026, 5, 3, 12));
    when(notifRepo.initialize).thenAnswer((_) async {});
    when(notifRepo.cancelAll).thenAnswer((_) async {});
    when(notifRepo.cancelPeriodReminders).thenAnswer((_) async {});
    when(
      () => notifRepo.schedulePeriodStarting(
        when: any(named: 'when'),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) async {});

    coordinator = NotificationsCoordinator(
      authRepository: authRepo,
      cycleRepository: cycleRepo,
      notificationsRepository: notifRepo,
      clock: clock,
    );
  });

  Cycle cycleWithPredicted(DateTime predictedNextStart) {
    return CycleFactory.make(
      startDate: DateTime.utc(2026, 4, 19),
      predictedNextStart: predictedNextStart,
    );
  }

  test('cancels everything when the user signs out', () async {
    when(authRepo.watchAuthState).thenAnswer(
      (_) => Stream<AuthState>.value(const AuthStateUnauthenticated()),
    );

    await coordinator.start();
    await Future<void>.delayed(Duration.zero);

    verify(notifRepo.initialize).called(1);
    verify(notifRepo.cancelAll).called(greaterThanOrEqualTo(1));
  });

  test('schedules a reminder when paired user has a future predicted period',
      () async {
    final paired = UserFactory.owner().copyWith(
      notificationsEnabled: true,
    );
    when(authRepo.watchAuthState).thenAnswer(
      (_) => Stream<AuthState>.value(AuthStateAuthenticated(paired)),
    );
    when(() => cycleRepo.watchCurrentCycle('couple-1')).thenAnswer(
      (_) => Stream<Cycle?>.value(
        cycleWithPredicted(DateTime.utc(2026, 5, 17)),
      ),
    );

    await coordinator.start();
    await Future<void>.delayed(Duration.zero);

    final captured = verify(
      () => notifRepo.schedulePeriodStarting(
        when: captureAny(named: 'when'),
        language: AppLanguage.ptBr,
      ),
    ).captured.single as DateTime;
    // Schedule = predicted - 1 day at 09:00 local → May 16 09:00.
    expect(captured.year, 2026);
    expect(captured.month, 5);
    expect(captured.day, 16);
    expect(captured.hour, 9);
  });

  test('does not schedule when notificationsEnabled is false', () async {
    final paired = UserFactory.owner();
    // notificationsEnabled defaults to false.
    when(authRepo.watchAuthState).thenAnswer(
      (_) => Stream<AuthState>.value(AuthStateAuthenticated(paired)),
    );
    when(() => cycleRepo.watchCurrentCycle('couple-1')).thenAnswer(
      (_) => Stream<Cycle?>.value(
        cycleWithPredicted(DateTime.utc(2026, 5, 17)),
      ),
    );

    await coordinator.start();
    await Future<void>.delayed(Duration.zero);

    verifyNever(
      () => notifRepo.schedulePeriodStarting(
        when: any(named: 'when'),
        language: any(named: 'language'),
      ),
    );
  });

  test('does not schedule when the predicted reminder time is in the past',
      () async {
    final paired = UserFactory.owner().copyWith(
      notificationsEnabled: true,
    );
    when(authRepo.watchAuthState).thenAnswer(
      (_) => Stream<AuthState>.value(AuthStateAuthenticated(paired)),
    );
    // Predicted yesterday → reminder time was the day before yesterday.
    when(() => cycleRepo.watchCurrentCycle('couple-1')).thenAnswer(
      (_) => Stream<Cycle?>.value(
        cycleWithPredicted(DateTime.utc(2026, 5, 2)),
      ),
    );

    await coordinator.start();
    await Future<void>.delayed(Duration.zero);

    verifyNever(
      () => notifRepo.schedulePeriodStarting(
        when: any(named: 'when'),
        language: any(named: 'language'),
      ),
    );
  });

  test('cancels period reminders when the cycle has no predicted date',
      () async {
    final paired = UserFactory.owner().copyWith(
      notificationsEnabled: true,
    );
    when(authRepo.watchAuthState).thenAnswer(
      (_) => Stream<AuthState>.value(AuthStateAuthenticated(paired)),
    );
    when(() => cycleRepo.watchCurrentCycle('couple-1')).thenAnswer(
      (_) => Stream<Cycle?>.value(
        CycleFactory.firstEver(), // no predictedNextStart
      ),
    );

    await coordinator.start();
    await Future<void>.delayed(Duration.zero);

    verify(notifRepo.cancelPeriodReminders).called(greaterThanOrEqualTo(1));
    verifyNever(
      () => notifRepo.schedulePeriodStarting(
        when: any(named: 'when'),
        language: any(named: 'language'),
      ),
    );
  });
}
