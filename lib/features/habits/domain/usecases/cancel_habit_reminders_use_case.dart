import '../../../../core/notifications/notification_service.dart';
import 'schedule_habit_reminders_use_case.dart';

/// Use case for cancelling scheduled reminder notifications for a habit.
class CancelHabitRemindersUseCase {
  final NotificationService _notificationService;

  const CancelHabitRemindersUseCase(this._notificationService);

  /// Cancels any active or scheduled reminders for the habit identified by [habitId].
  Future<void> execute(String habitId) {
    final notificationId =
        ScheduleHabitRemindersUseCase.getNotificationId(habitId);
    return _notificationService.cancelNotification(notificationId);
  }
}
