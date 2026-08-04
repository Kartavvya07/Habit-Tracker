import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/usecases/archive_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/create_habit_use_case.dart';

import 'create_habit_use_case_test.dart';

void main() {
  late FakeHabitRepository repository;
  late CreateHabitUseCase createHabitUseCase;
  late ArchiveHabitUseCase archiveHabitUseCase;

  setUp(() {
    repository = FakeHabitRepository();
    createHabitUseCase = CreateHabitUseCase(repository);
    archiveHabitUseCase = ArchiveHabitUseCase(repository);
  });

  final now = DateTime.parse('2026-07-24T12:00:00.000Z');
  final testHabit = Habit(
    id: 'habit-archive-1',
    title: 'Morning Yoga',
    description: '15 mins stretch',
    icon: 'yoga',
    color: HabitColor.green,
    frequency: HabitFrequency.daily,
    habitType: HabitType.boolean,
    targetCount: 1,
    createdAt: now,
    updatedAt: now,
    isArchived: false,
  );

  group('ArchiveHabitUseCase Tests', () {
    test('archives habit by updating isArchived to true', () async {
      await createHabitUseCase.execute(testHabit);
      expect((await repository.getHabit('habit-archive-1'))?.isArchived, isFalse);

      await archiveHabitUseCase.execute('habit-archive-1');

      final archivedHabit = await repository.getHabit('habit-archive-1');
      expect(archivedHabit, isNotNull);
      expect(archivedHabit?.isArchived, isTrue);
    });
  });
}
