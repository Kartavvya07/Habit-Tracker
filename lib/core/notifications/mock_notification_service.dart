import 'notification_service.dart';

/// A mock implementation of [NotificationService] for unit and widget testing.
class MockNotificationService implements NotificationService {
  bool initialized = false;
  bool permissionsGranted = true;
  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<int> cancelledNotificationIds = [];

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    permissionsGranted = true;
    return true;
  }

  @override
  Future<bool> hasPermissions() async {
    return permissionsGranted;
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'payload': payload,
    });
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelledNotificationIds.add(id);
    scheduledNotifications.removeWhere((n) => n['id'] == id);
  }

  @override
  Future<void> showNotificationNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': DateTime.now(),
      'payload': payload,
      'immediate': true,
    });
  }

  @override
  Future<List<dynamic>> getPendingNotifications() async {
    return scheduledNotifications;
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelledNotificationIds.addAll(
        scheduledNotifications.map((n) => n['id'] as int).toList());
    scheduledNotifications.clear();
  }
}
