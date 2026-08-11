import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/habits/data/repositories/drift_habit_repository.dart';
import '../../features/habits/domain/entities/habit_log.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/log_habit_progress_use_case.dart';
import '../../features/habits/domain/usecases/schedule_habit_reminders_use_case.dart';
import '../database/app_database.dart';
import 'local_notification_service_impl.dart';

/// Handler for interactive notification action buttons ('Mark Complete', 'Snooze 15m').
class NotificationActionHandler {
  static const String markCompleteActionId = 'mark_complete';
  static const String snooze15mActionId = 'snooze_15m';

  /// Top-level or static background handler invoked when a user taps a notification action button.
  @pragma('vm:entry-point')
  static Future<void> handleNotificationResponse(
    NotificationResponse response, [
    HabitRepository? testRepository,
  ]) async {
    final actionId = response.actionId;
    final habitId = response.payload;

    if (habitId == null || habitId.isEmpty) return;

    try {
      if (actionId == markCompleteActionId) {
        if (testRepository != null) {
          final logUseCase = LogHabitProgressUseCase(testRepository);
          await logUseCase.execute(
            habitId: habitId,
            status: HabitLogStatus.completed,
          );
        } else {
          final dbFolder = await getApplicationDocumentsDirectory();
          final file = File(p.join(dbFolder.path, 'habit_tracker.sqlite'));
          final db = AppDatabase(NativeDatabase.createInBackground(file));
          final repository = DriftHabitRepository(db);
          final logUseCase = LogHabitProgressUseCase(repository);

          await logUseCase.execute(
            habitId: habitId,
            status: HabitLogStatus.completed,
          );
          await db.close();
        }
      } else if (actionId == snooze15mActionId) {
        final notificationService = LocalNotificationServiceImpl();
        final snoozeDate = DateTime.now().add(const Duration(minutes: 15));
        final notificationId =
            ScheduleHabitRemindersUseCase.getNotificationId(habitId) + 9999;

        await notificationService.scheduleNotification(
          id: notificationId,
          title: 'Snoozed Habit',
          body: 'Time to complete your habit!',
          scheduledDate: snoozeDate,
          payload: habitId,
        );
      }
    } catch (_) {
      // Handle background execution errors gracefully
    }
  }
}
