import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local_notification_service_impl.dart';
import 'notification_service.dart';

/// Provider for [NotificationService].
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationServiceImpl();
});
