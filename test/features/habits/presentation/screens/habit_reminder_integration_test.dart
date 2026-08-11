import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/notifications/mock_notification_service.dart';
import 'package:habit_tracker/core/notifications/notification_provider.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/providers/use_case_providers.dart';

import '../providers/create_habit_notifier_test.dart';

void main() {
  group('Habit Reminder Mock Integration Tests', () {
    late MockHabitRepository repository;
    late MockNotificationService mockNotificationService;
    late ProviderContainer container;

    setUp(() {
      repository = MockHabitRepository();
      mockNotificationService = MockNotificationService();

      container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          notificationServiceProvider.overrideWithValue(mockNotificationService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Creating a habit with reminder enabled schedules notification', () async {
      final createHabitUseCase = container.read(createHabitUseCaseProvider);

      final now = DateTime.now();
      final habit = Habit(
        id: 'integration-habit-1',
        title: 'Morning Yoga',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '07:30',
      );

      await createHabitUseCase.execute(habit);

      expect(repository.savedHabits.length, equals(1));
      expect(mockNotificationService.scheduledNotifications.length, equals(1));
      expect(
        mockNotificationService.scheduledNotifications.first['title'],
        equals('Morning Yoga'),
      );
    });

    test('Updating a habit to disable reminder cancels notification', () async {
      final now = DateTime.now();
      final habit = Habit(
        id: 'integration-habit-2',
        title: 'Meditation',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '08:00',
      );
      repository.savedHabits.add(habit);

      final createHabitUseCase = container.read(createHabitUseCaseProvider);
      await createHabitUseCase.execute(habit);

      expect(mockNotificationService.scheduledNotifications.length, equals(1));

      final updateHabitUseCase = container.read(updateHabitUseCaseProvider);
      final updatedHabit = habit.copyWith(isReminderEnabled: false);
      await updateHabitUseCase.execute(updatedHabit);

      expect(mockNotificationService.scheduledNotifications, isEmpty);
    });

    test('Archiving habit cancels scheduled notification', () async {
      final now = DateTime.now();
      final habit = Habit(
        id: 'integration-habit-3',
        title: 'Read Article',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '21:00',
      );
      repository.savedHabits.add(habit);

      final createHabitUseCase = container.read(createHabitUseCaseProvider);
      await createHabitUseCase.execute(habit);

      expect(mockNotificationService.scheduledNotifications.length, equals(1));

      final archiveHabitUseCase = container.read(archiveHabitUseCaseProvider);
      await archiveHabitUseCase.execute('integration-habit-3');

      expect(mockNotificationService.scheduledNotifications, isEmpty);
    });

    test('Deleting habit cancels scheduled notification', () async {
      final now = DateTime.now();
      final habit = Habit(
        id: 'integration-habit-4',
        title: 'Journaling',
        createdAt: now,
        updatedAt: now,
        isReminderEnabled: true,
        reminderTime: '22:00',
      );
      repository.savedHabits.add(habit);

      final createHabitUseCase = container.read(createHabitUseCaseProvider);
      await createHabitUseCase.execute(habit);

      expect(mockNotificationService.scheduledNotifications.length, equals(1));

      final deleteHabitUseCase = container.read(deleteHabitUseCaseProvider);
      await deleteHabitUseCase.execute('integration-habit-4');

      expect(mockNotificationService.scheduledNotifications, isEmpty);
    });
  });
}
