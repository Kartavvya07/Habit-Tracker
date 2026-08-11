import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_notification_service_impl.dart';
import 'mock_notification_service.dart';
import 'notification_service.dart';

bool _isTestEnvironment() {
  try {
    final binding = ServicesBinding.instance.runtimeType.toString();
    return binding.contains('Test') || binding.contains('Binding');
  } catch (_) {
    return true;
  }
}

/// Provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  if (_isTestEnvironment()) {
    return MockNotificationService();
  }
  return LocalNotificationServiceImpl();
});
