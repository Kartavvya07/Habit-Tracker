import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/notifications/notification_service.dart';

class MockNotificationService implements NotificationService {
  bool initialized = false;
  bool permissionsGranted = false;
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
  Future<void> cancelAllNotifications() async {
    cancelledNotificationIds.addAll(
        scheduledNotifications.map((n) => n['id'] as int).toList());
    scheduledNotifications.clear();
  }
}

void main() {
  group('NotificationService Contract Tests', () {
    late MockNotificationService notificationService;

    setUp(() {
      notificationService = MockNotificationService();
    });

    test('initialize sets initialized to true', () async {
      expect(notificationService.initialized, isFalse);
      await notificationService.initialize();
      expect(notificationService.initialized, isTrue);
    });

    test('requestPermissions returns granted state', () async {
      expect(await notificationService.hasPermissions(), isFalse);
      final result = await notificationService.requestPermissions();
      expect(result, isTrue);
      expect(await notificationService.hasPermissions(), isTrue);
    });

    test('scheduleNotification records scheduled payload correctly', () async {
      final scheduledDate = DateTime.now().add(const Duration(hours: 1));
      await notificationService.scheduleNotification(
        id: 101,
        title: 'Morning Drink Water',
        body: 'Time to log 250ml water!',
        scheduledDate: scheduledDate,
        payload: 'habit_101',
      );

      expect(notificationService.scheduledNotifications.length, equals(1));
      final notification = notificationService.scheduledNotifications.first;
      expect(notification['id'], equals(101));
      expect(notification['title'], equals('Morning Drink Water'));
      expect(notification['scheduledDate'], equals(scheduledDate));
      expect(notification['payload'], equals('habit_101'));
    });

    test('cancelNotification removes specific notification', () async {
      await notificationService.scheduleNotification(
        id: 202,
        title: 'Exercise',
        body: 'Time for workout',
        scheduledDate: DateTime.now().add(const Duration(minutes: 30)),
      );

      expect(notificationService.scheduledNotifications.length, equals(1));
      await notificationService.cancelNotification(202);
      expect(notificationService.scheduledNotifications, isEmpty);
      expect(notificationService.cancelledNotificationIds, contains(202));
    });

    test('cancelAllNotifications clears all pending alarms', () async {
      await notificationService.scheduleNotification(
        id: 1,
        title: 'H1',
        body: 'B1',
        scheduledDate: DateTime.now(),
      );
      await notificationService.scheduleNotification(
        id: 2,
        title: 'H2',
        body: 'B2',
        scheduledDate: DateTime.now(),
      );

      expect(notificationService.scheduledNotifications.length, equals(2));
      await notificationService.cancelAllNotifications();
      expect(notificationService.scheduledNotifications, isEmpty);
      expect(notificationService.cancelledNotificationIds, equals([1, 2]));
    });
  });
}
