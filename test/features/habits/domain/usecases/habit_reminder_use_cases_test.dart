import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/archive_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/cancel_habit_reminders_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/create_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/restore_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/schedule_habit_reminders_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/update_habit_use_case.dart';

import '../../../../core/notifications/notification_service_test.dart';

class MockHabitRepository implements HabitRepository {
  final Map<String, Habit> habits = {};
  final List<HabitLog> loggedEntries = [];

  @override
  Future<void> saveHabitLog(HabitLog log) async {
    loggedEntries.add(log);
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    return habits.values.where((h) => !h.isArchived).toList();
  }

  @override
  Future<List<HabitLog>> getLogsForHabitAndDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return loggedEntries.where((l) => l.habitId == habitId).toList();
  }

  @override
  Future<void> createHabit(Habit habit) async {
    habits[habit.id] = habit;
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    habits[habit.id] = habit;
  }

  @override
  Future<void> archiveHabit(String id) async {
    if (habits.containsKey(id)) {
      habits[id] = habits[id]!.copyWith(isArchived: true);
    }
  }

  @override
  Future<void> restoreHabit(String id) async {
    if (habits.containsKey(id)) {
      habits[id] = habits[id]!.copyWith(isArchived: false);
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    habits.remove(id);
  }

  @override
  Future<Habit?> getHabit(String id) async {
    return habits[id];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Habit Reminder Scheduling Math Tests', () {
    final now = DateTime(2026, 8, 11, 10, 0); // 10:00 AM

    test('computeNextReminderDateTime calculates today if target time is in future', () {
      final habit = Habit(
        id: 'h1',
        title: 'Morning Meditation',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '14:30', // 2:30 PM
        frequency: HabitFrequency.daily,
      );

      final next = ScheduleHabitRemindersUseCase.computeNextReminderDateTime(habit, now);
      expect(next, equals(DateTime(2026, 8, 11, 14, 30)));
    });

    test('computeNextReminderDateTime calculates tomorrow if target time has passed', () {
      final habit = Habit(
        id: 'h2',
        title: 'Early Workout',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '08:00', // 8:00 AM (past)
        frequency: HabitFrequency.daily,
      );

      final next = ScheduleHabitRemindersUseCase.computeNextReminderDateTime(habit, now);
      expect(next, equals(DateTime(2026, 8, 12, 8, 0)));
    });

    test('computeNextReminderDateTime respects weekly frequency', () {
      final habit = Habit(
        id: 'h3',
        title: 'Weekly Review',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '08:00', // past
        frequency: HabitFrequency.weekly,
      );

      final next = ScheduleHabitRemindersUseCase.computeNextReminderDateTime(habit, now);
      expect(next, equals(DateTime(2026, 8, 18, 8, 0)));
    });

    test('computeNextReminderDateTime returns null if reminder is disabled or archived', () {
      final disabledHabit = Habit(
        id: 'h4',
        title: 'Disabled Habit',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: false,
        reminderTime: '09:00',
      );

      final archivedHabit = Habit(
        id: 'h5',
        title: 'Archived Habit',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '09:00',
        isArchived: true,
      );

      expect(ScheduleHabitRemindersUseCase.computeNextReminderDateTime(disabledHabit, now), isNull);
      expect(ScheduleHabitRemindersUseCase.computeNextReminderDateTime(archivedHabit, now), isNull);
    });
  });

  group('Habit Lifecycle Reminder Integration Tests', () {
    late MockHabitRepository repository;
    late MockNotificationService notificationService;
    late ScheduleHabitRemindersUseCase scheduleUseCase;
    late CancelHabitRemindersUseCase cancelUseCase;

    setUp(() {
      repository = MockHabitRepository();
      notificationService = MockNotificationService();
      scheduleUseCase = ScheduleHabitRemindersUseCase(notificationService);
      cancelUseCase = CancelHabitRemindersUseCase(notificationService);
    });

    test('CreateHabitUseCase schedules notification when reminder is enabled', () async {
      final createHabitUseCase = CreateHabitUseCase(repository, scheduleUseCase);
      final habit = Habit(
        id: 'habit-101',
        title: 'Read Book',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isReminderEnabled: true,
        reminderTime: '20:00',
      );

      await createHabitUseCase.execute(habit);

      expect(repository.habits.containsKey('habit-101'), isTrue);
      expect(notificationService.scheduledNotifications.length, equals(1));
      expect(notificationService.scheduledNotifications.first['payload'], equals('habit-101'));
    });

    test('UpdateHabitUseCase cancels old schedule and schedules new reminder', () async {
      final createHabitUseCase = CreateHabitUseCase(repository, scheduleUseCase);
      final updateHabitUseCase = UpdateHabitUseCase(repository, scheduleUseCase, cancelUseCase);

      final habit = Habit(
        id: 'habit-102',
        title: 'Run',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isReminderEnabled: true,
        reminderTime: '07:00',
      );

      await createHabitUseCase.execute(habit);
      expect(notificationService.scheduledNotifications.length, equals(1));

      final updatedHabit = habit.copyWith(reminderTime: '19:00');
      await updateHabitUseCase.execute(updatedHabit);

      expect(notificationService.cancelledNotificationIds, contains(ScheduleHabitRemindersUseCase.getNotificationId('habit-102')));
      expect(notificationService.scheduledNotifications.length, equals(1));
    });

    test('ArchiveHabitUseCase cancels scheduled reminders', () async {
      final createHabitUseCase = CreateHabitUseCase(repository, scheduleUseCase);
      final archiveHabitUseCase = ArchiveHabitUseCase(repository, cancelUseCase);

      final habit = Habit(
        id: 'habit-103',
        title: 'Meditate',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isReminderEnabled: true,
        reminderTime: '21:00',
      );

      await createHabitUseCase.execute(habit);
      expect(notificationService.scheduledNotifications.length, equals(1));

      await archiveHabitUseCase.execute('habit-103');
      expect(notificationService.scheduledNotifications, isEmpty);
      expect(notificationService.cancelledNotificationIds, contains(ScheduleHabitRemindersUseCase.getNotificationId('habit-103')));
    });

    test('RestoreHabitUseCase reschedules active reminders', () async {
      final createHabitUseCase = CreateHabitUseCase(repository, scheduleUseCase);
      final archiveHabitUseCase = ArchiveHabitUseCase(repository, cancelUseCase);
      final restoreHabitUseCase = RestoreHabitUseCase(repository, scheduleUseCase);

      final habit = Habit(
        id: 'habit-104',
        title: 'Journal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isReminderEnabled: true,
        reminderTime: '22:00',
      );

      await createHabitUseCase.execute(habit);
      await archiveHabitUseCase.execute('habit-104');
      expect(notificationService.scheduledNotifications, isEmpty);

      await restoreHabitUseCase.execute('habit-104');
      expect(notificationService.scheduledNotifications.length, equals(1));
    });

    test('DeleteHabitUseCase permanently cancels all associated reminders', () async {
      final createHabitUseCase = CreateHabitUseCase(repository, scheduleUseCase);
      final deleteHabitUseCase = DeleteHabitUseCase(repository, cancelUseCase);

      final habit = Habit(
        id: 'habit-105',
        title: 'Stretch',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isReminderEnabled: true,
        reminderTime: '06:30',
      );

      await createHabitUseCase.execute(habit);
      expect(notificationService.scheduledNotifications.length, equals(1));

      await deleteHabitUseCase.execute('habit-105');
      expect(notificationService.scheduledNotifications, isEmpty);
      expect(repository.habits.containsKey('habit-105'), isFalse);
    });
  });
}
