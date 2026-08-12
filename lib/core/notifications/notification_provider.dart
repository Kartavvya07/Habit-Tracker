import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_notification_service_impl.dart';
import 'mock_notification_service.dart';
import 'notification_service.dart';

bool _isTestEnvironment() {
  try {
    return Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return false;
  }
}

/// Provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  if (_isTestEnvironment()) {
    return MockNotificationService();
  }
  return LocalNotificationServiceImpl();
});
