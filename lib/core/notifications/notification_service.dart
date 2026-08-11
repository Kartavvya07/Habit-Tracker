/// Abstract interface for local notification management across platforms.
abstract class NotificationService {
  /// Initializes notification channels, timezone data, and plugin settings.
  Future<void> initialize();

  /// Requests notification permissions from the host platform.
  ///
  /// Returns `true` if permissions were granted, `false` otherwise.
  Future<bool> requestPermissions();

  /// Checks if notification permissions have been granted.
  Future<bool> hasPermissions();

  /// Schedules an exact local alarm/notification for the specified [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  });

  /// Cancels a specific scheduled notification by its [id].
  Future<void> cancelNotification(int id);

  /// Cancels all active and pending scheduled notifications.
  Future<void> cancelAllNotifications();
}
