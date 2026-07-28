import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/usecases/get_daily_completion_use_case.dart';

import 'log_habit_progress_use_case_test.dart';

void main() {
  late InMemoryHabitRepository repository;
  late GetDailyCompletionUseCase useCase;

  setUp(() {
    repository = InMemoryHabitRepository();
    useCase = GetDailyCompletionUseCase(repository);
  });

  group('GetDailyCompletionUseCase', () {
    final targetDate = DateTime(2026, 7, 28);

    final habit1 = Habit(
      id: 'h1',
      title: 'Habit 1',
      habitType: HabitType.boolean,
      createdAt: targetDate,
      updatedAt: targetDate,
    );

    final habit2 = Habit(
      id: 'h2',
      title: 'Habit 2',
      habitType: HabitType.boolean,
      createdAt: targetDate,
      updatedAt: targetDate,
    );

    final habitArchived = Habit(
      id: 'h3',
      title: 'Habit 3 (Archived)',
      habitType: HabitType.boolean,
      isArchived: true,
      createdAt: targetDate,
      updatedAt: targetDate,
    );

    test('returns empty stats when no active habits exist', () async {
      await repository.createHabit(habitArchived);

      final stats = await useCase.execute(targetDate: targetDate);

      expect(stats.totalHabits, equals(0));
      expect(stats.completedHabits, equals(0));
      expect(stats.completionPercentage, equals(0.0));
      expect(stats.isFullyCompleted, isFalse);
    });

    test('calculates partial completion accurately', () async {
      await repository.createHabit(habit1);
      await repository.createHabit(habit2);

      await repository.saveHabitLog(
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: targetDate,
          status: HabitLogStatus.completed,
        ),
      );

      final stats = await useCase.execute(targetDate: targetDate);

      expect(stats.totalHabits, equals(2));
      expect(stats.completedHabits, equals(1));
      expect(stats.completionPercentage, equals(0.5));
      expect(stats.isFullyCompleted, isFalse);
    });

    test('calculates full 100% completion accurately', () async {
      await repository.createHabit(habit1);
      await repository.createHabit(habit2);

      await repository.saveHabitLog(
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: targetDate,
          status: HabitLogStatus.completed,
        ),
      );
      await repository.saveHabitLog(
        HabitLog(
          id: 'l2',
          habitId: 'h2',
          targetDate: targetDate,
          status: HabitLogStatus.completed,
        ),
      );

      final stats = await useCase.execute(targetDate: targetDate);

      expect(stats.totalHabits, equals(2));
      expect(stats.completedHabits, equals(2));
      expect(stats.completionPercentage, equals(1.0));
      expect(stats.isFullyCompleted, isTrue);
    });
  });
}
