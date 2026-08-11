import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/notifications/notification_action_handler.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/usecases/reconcile_reminders_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/schedule_habit_reminders_use_case.dart';

import '../../features/habits/domain/usecases/habit_reminder_use_cases_test.dart';
import 'notification_service_test.dart';

void main() {
  group('NotificationActionHandler Tests', () {
    test('constants are correctly defined', () {
      expect(NotificationActionHandler.markCompleteActionId, equals('mark_complete'));
      expect(NotificationActionHandler.snooze15mActionId, equals('snooze_15m'));
    });

    test('handleNotificationResponse ignores null or empty payload', () async {
      const response = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        actionId: 'mark_complete',
        payload: null,
      );

      await NotificationActionHandler.handleNotificationResponse(response);
    });

    test('handleNotificationResponse logs completion on mark_complete action', () async {
      final repository = MockHabitRepository();
      final now = DateTime.now();
      final habit = Habit(
        id: 'h-action-1',
        title: 'Drink Water',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '10:00',
        targetCount: 1,
      );
      repository.habits['h-action-1'] = habit;

      const response = NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        actionId: NotificationActionHandler.markCompleteActionId,
        payload: 'h-action-1',
      );

      await NotificationActionHandler.handleNotificationResponse(response, repository);

      expect(repository.loggedEntries.length, equals(1));
      expect(repository.loggedEntries.first.status, equals(HabitLogStatus.completed));
    });
  });

  group('ReconcileRemindersUseCase Tests', () {
    late MockHabitRepository repository;
    late MockNotificationService notificationService;
    late ScheduleHabitRemindersUseCase scheduleUseCase;
    late ReconcileRemindersUseCase reconcileUseCase;

    setUp(() {
      repository = MockHabitRepository();
      notificationService = MockNotificationService();
      scheduleUseCase = ScheduleHabitRemindersUseCase(notificationService);
      reconcileUseCase = ReconcileRemindersUseCase(repository, scheduleUseCase);
    });

    test('execute reschedules reminders for all enabled active habits', () async {
      final now = DateTime.now();
      final habit1 = Habit(
        id: 'h-rec-1',
        title: 'Water',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '09:00',
      );
      final habit2 = Habit(
        id: 'h-rec-2',
        title: 'Exercise',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: false,
        reminderTime: '10:00',
      );
      final habit3 = Habit(
        id: 'h-rec-3',
        title: 'Sleep',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '23:00',
      );

      repository.habits['h-rec-1'] = habit1;
      repository.habits['h-rec-2'] = habit2;
      repository.habits['h-rec-3'] = habit3;

      await reconcileUseCase.execute();

      expect(notificationService.scheduledNotifications.length, equals(2));
      final scheduledIds = notificationService.scheduledNotifications
          .map((n) => n['payload'] as String)
          .toList();
      expect(scheduledIds, contains('h-rec-1'));
      expect(scheduledIds, contains('h-rec-3'));
      expect(scheduledIds, isNot(contains('h-rec-2')));
    });
  });
}
