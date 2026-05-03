import 'package:mycycle/core/entities/user.dart';

/// Wraps the platform notifications plugin behind a project-owned interface
/// so domain code (and tests) never touch `flutter_local_notifications`
/// directly.
abstract class NotificationsRepository {
  /// One-time setup — initialize the plugin, create channels, init timezones.
  /// Safe to call multiple times.
  Future<void> initialize();

  /// Asks the OS for notification permission (Android 13+ runtime). Returns
  /// `true` if granted (or already granted).
  Future<bool> requestPermission();

  /// Whether notifications can actually fire for this app right now.
  Future<bool> hasPermission();

  /// Schedule the "period likely starting tomorrow" reminder at [when]
  /// (local time). Cancels the previous occurrence if any.
  Future<void> schedulePeriodStarting({
    required DateTime when,
    required AppLanguage language,
  });

  /// Cancel the period-reminder notifications (does not affect other types).
  Future<void> cancelPeriodReminders();

  /// Cancel everything we scheduled. Used on sign-out.
  Future<void> cancelAll();
}
