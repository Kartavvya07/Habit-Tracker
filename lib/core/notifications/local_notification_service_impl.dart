import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_action_handler.dart';
import 'notification_service.dart';

/// Implementation of [NotificationService] using [FlutterLocalNotificationsPlugin].
class LocalNotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  static const String channelId = 'habit_reminders';
  static const String channelName = 'Habit Reminders';
  static const String channelDescription =
      'Notifications for scheduled habit reminders';

  LocalNotificationServiceImpl({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('[NotificationService] TimeZone initialized: $timeZoneName');
      } catch (e) {
        debugPrint('[NotificationService] TimeZone detection warning: $e');
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            _onBackgroundNotificationResponse,
      );

      await _createNotificationChannel();
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
    _isInitialized = true;
  }

  Future<void> _createNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(androidChannel);
    } catch (e) {
      debugPrint('[NotificationService] Error creating channel: $e');
    }
  }

  @pragma('vm:entry-point')
  static void _onNotificationResponse(NotificationResponse response) {
    NotificationActionHandler.handleNotificationResponse(response);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    NotificationActionHandler.handleNotificationResponse(response);
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted =
          await androidImpl?.requestNotificationsPermission() ?? false;
      await androidImpl?.requestExactAlarmsPermission();

      final iosImpl = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await iosImpl?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      return androidGranted || iosGranted;
    } catch (e) {
      debugPrint('[NotificationService] Error requesting permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImpl?.areNotificationsEnabled() ?? false;
      return granted;
    } catch (e) {
      debugPrint('[NotificationService] Error checking permissions: $e');
      return false;
    }
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      debugPrint('[NotificationService] Scheduling Notification ID: $id');
      debugPrint('[NotificationService] Title: "$title"');
      debugPrint('[NotificationService] Local scheduled timestamp: $scheduledDate');
      debugPrint('[NotificationService] TZ location: ${tz.local.name}');
      debugPrint('[NotificationService] Computed TZ timestamp: $scheduledTzDate');

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            NotificationActionHandler.markCompleteActionId,
            'Mark Complete',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            NotificationActionHandler.snooze15mActionId,
            'Snooze 15m',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final canExact = await androidImpl?.canScheduleExactNotifications() ?? true;
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDate,
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint('[NotificationService] SUCCESS: Scheduled Notification ID $id at $scheduledTzDate');
    } catch (e, st) {
      debugPrint('[NotificationService] ERROR scheduling Notification ID $id: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      debugPrint('[NotificationService] Cancelled Notification ID: $id');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling notification $id: $e');
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      debugPrint('[NotificationService] Cancelled all notifications');
    } catch (e) {
      debugPrint('[NotificationService] Error cancelling all notifications: $e');
    }
  }
}
