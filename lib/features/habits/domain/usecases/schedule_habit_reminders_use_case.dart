import 'package:flutter/foundation.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../settings/domain/repositories/vacation_mode_repository.dart';
import '../entities/habit.dart';
import '../entities/habit_frequency.dart';

/// Use case for calculating exact reminder alarm timestamps and scheduling
/// local notifications for a habit.
class ScheduleHabitRemindersUseCase {
  final NotificationService _notificationService;
  final VacationModeRepository? _vacationModeRepository;

  const ScheduleHabitRemindersUseCase(
    this._notificationService, [
    this._vacationModeRepository,
  ]);

  /// Helper to convert a string habit ID into a deterministic integer notification ID.
  static int getNotificationId(String habitId) {
    return habitId.hashCode.abs() % 2147483647;
  }

  /// Calculates the next trigger [DateTime] for a given [habit] after [fromDate].
  static DateTime? computeNextReminderDateTime(
    Habit habit, [
    DateTime? fromDate,
  ]) {
    if (!habit.isReminderEnabled ||
        habit.reminderTime == null ||
        habit.isArchived) {
      return null;
    }

    final parts = habit.reminderTime!.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final baseDate = fromDate ?? DateTime.now();
    var scheduled = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );

    final baseDateMinutePrecision = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      baseDate.hour,
      baseDate.minute,
    );

    if (scheduled.isBefore(baseDateMinutePrecision)) {
      switch (habit.frequency) {
        case HabitFrequency.daily:
          scheduled = scheduled.add(const Duration(days: 1));
          break;
        case HabitFrequency.weekly:
          scheduled = scheduled.add(const Duration(days: 7));
          break;
        case HabitFrequency.monthly:
          final nextMonth = DateTime(scheduled.year, scheduled.month + 1, 1);
          final lastDayOfNextMonth =
              DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
          final targetDay = scheduled.day > lastDayOfNextMonth
              ? lastDayOfNextMonth
              : scheduled.day;
          scheduled = DateTime(
            nextMonth.year,
            nextMonth.month,
            targetDay,
            hour,
            minute,
          );
          break;
      }
    }

    return scheduled;
  }

  /// Schedules the next reminder notification for [habit].
  Future<void> execute(Habit habit) async {
    final notificationId = getNotificationId(habit.id);

    // If Vacation Mode is active, cancel active schedule and return
    if (_vacationModeRepository != null) {
      final isVacationActive =
          await _vacationModeRepository.isVacationModeEnabled();
      if (isVacationActive) {
        debugPrint('[ScheduleHabitRemindersUseCase] Vacation Mode active -> cancelling Notification ID: $notificationId');
        await _notificationService.cancelNotification(notificationId);
        return;
      }
    }

    final nextTrigger = computeNextReminderDateTime(habit);

    if (nextTrigger == null) {
      debugPrint('[ScheduleHabitRemindersUseCase] Reminder disabled or invalid -> cancelling Notification ID: $notificationId');
      await _notificationService.cancelNotification(notificationId);
      return;
    }

    debugPrint('[ScheduleHabitRemindersUseCase] Habit: "${habit.title}" (ID: ${habit.id})');
    debugPrint('[ScheduleHabitRemindersUseCase] Reminder selected: ${habit.reminderTime}');
    debugPrint('[ScheduleHabitRemindersUseCase] Calculated notification time: $nextTrigger');
    debugPrint('[ScheduleHabitRemindersUseCase] Notification ID: $notificationId');

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: habit.title,
      body: habit.description.isNotEmpty
          ? habit.description
          : 'Time to complete your habit: ${habit.title}',
      scheduledDate: nextTrigger,
      payload: habit.id,
    );
  }
}
