import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/entities/streak_info.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/providers/streak_provider.dart';
import 'package:habit_tracker/features/settings/presentation/providers/vacation_mode_provider.dart';

import '../../../settings/presentation/providers/vacation_mode_provider_test.dart';
import '../../domain/usecases/log_habit_progress_use_case_test.dart';

void main() {
  late InMemoryHabitRepository repository;
  late FakeVacationModeRepository vacationRepository;
  late ProviderContainer container;

  setUp(() {
    repository = InMemoryHabitRepository();
    vacationRepository = FakeVacationModeRepository();
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
        vacationModeRepositoryProvider.overrideWithValue(vacationRepository),
      ],
    );
  });


  tearDown(() {
    container.dispose();
    repository.dispose();
  });

  group('streak_provider tests', () {
    final now = DateTime.now();
    final habit = Habit(
      id: 'h1',
      title: 'Meditation',
      habitType: HabitType.boolean,
      createdAt: now,
      updatedAt: now,
    );

    test('habitLogsStreamProvider emits logs for specified habit', () async {
      await repository.createHabit(habit);
      await repository.saveHabitLog(
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: now,
          status: HabitLogStatus.completed,
        ),
      );

      final asyncLogs =
          await container.read(habitLogsStreamProvider('h1').future);
      expect(asyncLogs.length, equals(1));
      expect(asyncLogs.first.habitId, equals('h1'));
    });

    test('streakProvider calculates and updates streak info reactively', () async {
      await repository.createHabit(habit);

      final emissions = <StreakInfo>[];
      final subscription = container.listen(
        streakProvider('h1'),
        (previous, next) {
          next.whenData(emissions.add);
        },
        fireImmediately: true,
      );

      await container.read(streakProvider('h1').future);
      expect(emissions.last.currentStreak, equals(0));

      await repository.saveHabitLog(
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: now,
          status: HabitLogStatus.completed,
        ),
      );

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last.currentStreak, equals(1));
      expect(emissions.last.bestStreak, equals(1));

      subscription.close();
    });

    test('streakProvider emits loading initial state before resolution', () {
      final state = container.read(streakProvider('h1'));
      expect(state, isA<AsyncLoading<StreakInfo>>());
    });
  });
}
