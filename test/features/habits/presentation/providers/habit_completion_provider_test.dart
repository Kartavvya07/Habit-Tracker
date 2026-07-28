import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/daily_completion_stats.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_completion_provider.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';

import '../../domain/usecases/log_habit_progress_use_case_test.dart';

void main() {
  late InMemoryHabitRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryHabitRepository();
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    repository.dispose();
  });

  group('habit_completion_provider tests', () {
    final now = DateTime.now();
    final habit1 = Habit(
      id: 'h1',
      title: 'Workout',
      habitType: HabitType.boolean,
      createdAt: now,
      updatedAt: now,
    );

    test('todayLogsStreamProvider emits logs from repository', () async {
      await repository.createHabit(habit1);
      final log = HabitLog(
        id: 'l1',
        habitId: 'h1',
        targetDate: now,
        status: HabitLogStatus.completed,
      );
      await repository.saveHabitLog(log);

      final asyncLogs = await container.read(todayLogsStreamProvider.future);
      expect(asyncLogs.length, equals(1));
      expect(asyncLogs.first.habitId, equals('h1'));
    });

    test('todayCompletionsProvider emits daily completion stats reactively', () async {
      await repository.createHabit(habit1);

      final emissions = <DailyCompletionStats>[];
      final subscription = container.listen(
        todayCompletionsProvider,
        (previous, next) {
          next.whenData(emissions.add);
        },
        fireImmediately: true,
      );

      await container.read(todayCompletionsProvider.future);
      expect(emissions.last.totalHabits, equals(1));
      expect(emissions.last.completedHabits, equals(0));
      expect(emissions.last.isFullyCompleted, isFalse);

      await repository.saveHabitLog(
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: now,
          status: HabitLogStatus.completed,
        ),
      );

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last.totalHabits, equals(1));
      expect(emissions.last.completedHabits, equals(1));
      expect(emissions.last.isFullyCompleted, isTrue);

      subscription.close();
    });

    test('handles initial loading state gracefully', () {
      final state = container.read(todayCompletionsProvider);
      expect(state, isA<AsyncLoading<DailyCompletionStats>>());
    });
  });
}
