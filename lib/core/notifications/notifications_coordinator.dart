import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:mycycle/core/clock/clock.dart';
import 'package:mycycle/core/entities/cycle.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:mycycle/features/auth/domain/auth_state.dart';
import 'package:mycycle/features/auth/domain/repositories/auth_repository.dart';
import 'package:mycycle/features/cycle/domain/repositories/cycle_repository.dart';

/// Long-lived service that listens to auth + cycle changes and re-schedules
/// the "period likely starting" local notification.
///
/// Schedule rule: at 09:00 local time, one day before
/// `currentCycle.predictedNextStart`. If the resulting moment is in the past
/// (e.g., the cycle is already started), the schedule is skipped.
class NotificationsCoordinator {
  NotificationsCoordinator({
    required AuthRepository authRepository,
    required CycleRepository cycleRepository,
    required NotificationsRepository notificationsRepository,
    required Clock clock,
  })  : _authRepo = authRepository,
        _cycleRepo = cycleRepository,
        _notifRepo = notificationsRepository,
        _clock = clock;

  final AuthRepository _authRepo;
  final CycleRepository _cycleRepo;
  final NotificationsRepository _notifRepo;
  final Clock _clock;

  StreamSubscription<AuthState>? _authSub;
  StreamSubscription<Cycle?>? _cycleSub;
  User? _currentUser;

  static const int _reminderHour = 9;

  /// Initialize the platform plugin and start listening to auth + cycle
  /// streams. Idempotent.
  Future<void> start() async {
    await _notifRepo.initialize();
    _authSub ??= _authRepo.watchAuthState().listen(_onAuthState);
  }

  Future<void> stop() async {
    await _authSub?.cancel();
    await _cycleSub?.cancel();
    _authSub = null;
    _cycleSub = null;
    _currentUser = null;
    await _notifRepo.cancelAll();
  }

  void _onAuthState(AuthState state) {
    unawaited(_cycleSub?.cancel());
    _cycleSub = null;

    if (state is! AuthStateAuthenticated) {
      _currentUser = null;
      unawaited(_notifRepo.cancelAll());
      return;
    }

    _currentUser = state.user;
    final coupleId = state.user.coupleId;
    if (coupleId == null) {
      // No couple yet — nothing to schedule.
      unawaited(_notifRepo.cancelPeriodReminders());
      return;
    }

    _cycleSub = _cycleRepo.watchCurrentCycle(coupleId).listen(
          _onCycleUpdate,
          onError: (Object e, StackTrace stack) {
            debugPrint('Coordinator cycle stream error: $e\n$stack');
          },
        );
  }

  Future<void> _onCycleUpdate(Cycle? cycle) async {
    final user = _currentUser;
    if (user == null) return;

    await _notifRepo.cancelPeriodReminders();

    if (!user.notificationsEnabled) return;
    if (cycle == null) return;
    final predicted = cycle.predictedNextStart;
    if (predicted == null) return;

    final scheduleAt = _scheduleTimeFor(predicted);
    if (!scheduleAt.isAfter(_clock.now())) return;

    await _notifRepo.schedulePeriodStarting(
      when: scheduleAt,
      language: user.language,
    );
  }

  /// Computes "one day before [predicted] at 09:00 local".
  DateTime _scheduleTimeFor(DateTime predicted) {
    final dayBefore = predicted.subtract(const Duration(days: 1));
    return DateTime(
      dayBefore.year,
      dayBefore.month,
      dayBefore.day,
      _reminderHour,
    );
  }
}
