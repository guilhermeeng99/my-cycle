import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mycycle/core/entities/user.dart';
import 'package:mycycle/core/notifications/notifications_repository.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Notification IDs are stable so we can cancel + reschedule predictably.
abstract final class _Ids {
  static const int periodStarting = 1001;
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const String _channelId = 'cycle_reminders';
  static const String _channelName = 'Cycle reminders';
  static const String _channelDescription =
      'Gentle reminders about your cycle.';

  /// Personal-app shortcut: hardcoded local timezone. If we ever distribute
  /// this beyond Brazil we'd swap to a runtime detection (`flutter_timezone`).
  static const String _localTimezoneName = 'America/Sao_Paulo';

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_localTimezoneName));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<bool> hasPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final enabled = await android?.areNotificationsEnabled();
    return enabled ?? false;
  }

  @override
  Future<void> schedulePeriodStarting({
    required DateTime when,
    required AppLanguage language,
  }) async {
    await initialize();
    await _plugin.cancel(id: _Ids.periodStarting);

    final scheduled = tz.TZDateTime.from(when, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      // Don't schedule notifications in the past.
      return;
    }

    final (title, body) = _periodStartingCopy(language);

    try {
      await _plugin.zonedSchedule(
        id: _Ids.periodStarting,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Object catch (e, stack) {
      // Permission denied or platform-level scheduling rejection — surface
      // as debug log; UI doesn't need to know per call.
      debugPrint('schedulePeriodStarting failed: $e\n$stack');
    }
  }

  @override
  Future<void> cancelPeriodReminders() async {
    await initialize();
    await _plugin.cancel(id: _Ids.periodStarting);
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  /// Localized copy. Slang is async-init for non-base locales, so we keep
  /// notification strings hand-translated here — avoids a chicken-and-egg
  /// initialization issue between slang and the notifications coordinator.
  (String, String) _periodStartingCopy(AppLanguage language) {
    return switch (language) {
      AppLanguage.en => (
        'Heads up',
        'Your period is likely starting tomorrow. How are you feeling?',
      ),
      AppLanguage.ptBr => (
        'Aviso',
        'Sua menstruação deve começar amanhã. Tudo bem por aí?',
      ),
    };
  }
}
