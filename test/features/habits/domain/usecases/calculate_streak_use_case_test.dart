import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/usecases/calculate_streak_use_case.dart';

import 'log_habit_progress_use_case_test.dart';

void main() {
  late InMemoryHabitRepository repository;
  late CalculateStreakUseCase useCase;

  setUp(() {
    repository = InMemoryHabitRepository();
    useCase = CalculateStreakUseCase(repository);
  });

  group('CalculateStreakUseCase Edge Cases', () {
    final habit = Habit(
      id: 'h1',
      title: 'Daily Exercise',
      frequency: HabitFrequency.daily,
      habitType: HabitType.boolean,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('1. returns zero metrics when no logs exist', () async {
      await repository.createHabit(habit);
      final refDate = DateTime(2026, 1, 10);

      final streak = useCase.calculate(habit, [], referenceDate: refDate);

      expect(streak.currentStreak, equals(0));
      expect(streak.bestStreak, equals(0));
      expect(streak.completionRate, equals(0.0));
      expect(streak.totalCompleted, equals(0));
    });

    test('2. single day completed today gives 1 current and 1 best streak', () {
      final refDate = DateTime(2026, 1, 10);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: refDate,
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(1));
      expect(streak.bestStreak, equals(1));
    });

    test('3. single day completed yesterday, today incomplete yet gives 1 current streak', () {
      final refDate = DateTime(2026, 1, 10);
      final yesterday = DateTime(2026, 1, 9);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: yesterday,
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(1));
      expect(streak.bestStreak, equals(1));
    });

    test('4. 5 consecutive completed days up to today gives 5 current and 5 best streak', () {
      final refDate = DateTime(2026, 1, 10);
      final logs = List.generate(
        5,
        (i) => HabitLog(
          id: 'l$i',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 6 + i),
          status: HabitLogStatus.completed,
        ),
      );

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(5));
      expect(streak.bestStreak, equals(5));
    });

    test('5. gap 2 days ago breaks current streak', () {
      final refDate = DateTime(2026, 1, 10);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 5),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 6),
          status: HabitLogStatus.completed,
        ),
        // Missed Jan 7 & 8
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 9),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l4',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 10),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(2));
      expect(streak.bestStreak, equals(2));
    });

    test('6. historical max streak is retained when current streak is smaller', () {
      final refDate = DateTime(2026, 1, 20);
      final logs = [
        // 10-day streak in early Jan
        for (int i = 1; i <= 10; i++)
          HabitLog(
            id: 'l_hist_$i',
            habitId: 'h1',
            targetDate: DateTime(2026, 1, i),
            status: HabitLogStatus.completed,
          ),
        // Missed Jan 11-17
        HabitLog(
          id: 'l_curr_1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 19),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l_curr_2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 20),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(2));
      expect(streak.bestStreak, equals(10));
    });

    test('7. frozen day (isFrozen = true) protects streak', () {
      final refDate = DateTime(2026, 1, 5);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.inProgress,
          isFrozen: true,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 4),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l4',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 5),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(3));
    });

    test('8. skipped status protects streak', () {
      final refDate = DateTime(2026, 1, 4);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.skipped,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 4),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(2));
    });

    test('9. failed log breaks streak', () {
      final refDate = DateTime(2026, 1, 3);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.failed,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(1));
      expect(streak.bestStreak, equals(1));
    });

    test('10. leap year calculation across Feb 28 -> Feb 29 -> Mar 1 (2028 leap year)', () {
      final leapHabit = habit.copyWith(createdAt: DateTime(2028, 2, 27));
      final refDate = DateTime(2028, 3, 1);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2028, 2, 28),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2028, 2, 29),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2028, 3, 1),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(leapHabit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(3));
    });

    test('11. month boundary calculation (Jan 31 -> Feb 1)', () {
      final refDate = DateTime(2026, 2, 1);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 31),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 2, 1),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(2));
    });

    test('12. year boundary calculation (Dec 31 -> Jan 1)', () {
      final newYearHabit = habit.copyWith(createdAt: DateTime(2025, 12, 30));
      final refDate = DateTime(2026, 1, 1);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2025, 12, 31),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(newYearHabit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(2));
    });

    test('13. habit created today with completion gives 1 streak and 1.0 rate', () {
      final todayDate = DateTime(2026, 7, 28);
      final newHabit = habit.copyWith(createdAt: todayDate);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: todayDate,
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(newHabit, logs, referenceDate: todayDate);

      expect(streak.currentStreak, equals(1));
      expect(streak.bestStreak, equals(1));
      expect(streak.completionRate, equals(1.0));
    });

    test('14. handles out-of-order logs correctly', () {
      final refDate = DateTime(2026, 1, 3);
      final logs = [
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(3));
    });

    test('15. resolves duplicate logs on same day taking completed log', () {
      final refDate = DateTime(2026, 1, 1);
      final logs = [
        HabitLog(
          id: 'l1_in_prog',
          habitId: 'h1',
          targetDate: refDate,
          status: HabitLogStatus.inProgress,
        ),
        HabitLog(
          id: 'l1_completed',
          habitId: 'h1',
          targetDate: refDate,
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.currentStreak, equals(1));
    });

    test('16. completion rate calculated accurately over scheduled days', () {
      final refDate = DateTime(2026, 1, 4);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.failed,
        ),
        HabitLog(
          id: 'l4',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 4),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(habit, logs, referenceDate: refDate);

      expect(streak.totalCompleted, equals(3));
      expect(streak.totalScheduled, equals(4));
      expect(streak.completionRate, equals(0.75));
    });

    test('17. repository integration with execute method', () async {
      await repository.createHabit(habit);
      final refDate = DateTime(2026, 1, 2);
      await repository.saveHabitLog(
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
      );
      await repository.saveHabitLog(
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
      );

      final streak = await useCase.execute(habitId: 'h1', referenceDate: refDate);

      expect(streak.currentStreak, equals(2));
      expect(streak.bestStreak, equals(2));
    });

    test('18. Vacation Mode active preserves streak on missed days without falsely increasing it', () {
      final refDate = DateTime(2026, 1, 5);
      // User completed 3 days (Jan 1, Jan 2, Jan 3), then missed Jan 4 and Jan 5 while in Vacation Mode
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(
        habit,
        logs,
        referenceDate: refDate,
        isVacationModeActive: true,
      );

      // Streak remains 3 (preserved, not broken to 0, and not falsely increased to 5)
      expect(streak.currentStreak, equals(3));
      expect(streak.bestStreak, equals(3));
    });

    test('19. Vacation Mode disabled resets streak on missed days', () {
      final refDate = DateTime(2026, 1, 5);
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(
        habit,
        logs,
        referenceDate: refDate,
        isVacationModeActive: false,
      );

      // Missed Jan 4 breaks streak to 0
      expect(streak.currentStreak, equals(0));
      expect(streak.bestStreak, equals(3));
    });

    test('20. Streak resumes and increments cleanly after returning from Vacation Mode', () {
      final refDate = DateTime(2026, 1, 6);
      // Completed Jan 1-3, missed Jan 4-5 on vacation, completed Jan 6 after returning
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 1),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l2',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 2),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l3',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 3),
          status: HabitLogStatus.completed,
        ),
        HabitLog(
          id: 'l4',
          habitId: 'h1',
          targetDate: DateTime(2026, 1, 6),
          status: HabitLogStatus.completed,
        ),
      ];

      final streak = useCase.calculate(
        habit,
        logs,
        referenceDate: refDate,
        isVacationModeActive: true,
      );

      // Preserved 3 + 1 completed today = 4 current streak
      expect(streak.currentStreak, equals(4));
      expect(streak.bestStreak, equals(4));
    });
  });
}

