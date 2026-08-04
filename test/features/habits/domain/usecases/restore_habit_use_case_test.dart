import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/usecases/create_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/restore_habit_use_case.dart';

import 'create_habit_use_case_test.dart';

void main() {
  late FakeHabitRepository repository;
  late CreateHabitUseCase createHabitUseCase;
  late RestoreHabitUseCase restoreHabitUseCase;

  setUp(() {
    repository = FakeHabitRepository();
    createHabitUseCase = CreateHabitUseCase(repository);
    restoreHabitUseCase = RestoreHabitUseCase(repository);
  });

  final now = DateTime.parse('2026-07-24T12:00:00.000Z');
  final testArchivedHabit = Habit(
    id: 'habit-restore-1',
    title: 'Night Meditation',
    description: '10 mins mindfulness',
    icon: 'meditation',
    color: HabitColor.indigo,
    frequency: HabitFrequency.daily,
    habitType: HabitType.boolean,
    targetCount: 1,
    createdAt: now,
    updatedAt: now,
    isArchived: true,
  );

  group('RestoreHabitUseCase Tests', () {
    test('restores archived habit by updating isArchived to false', () async {
      await createHabitUseCase.execute(testArchivedHabit);
      expect((await repository.getHabit('habit-restore-1'))?.isArchived, isTrue);

      await restoreHabitUseCase.execute('habit-restore-1');

      final restoredHabit = await repository.getHabit('habit-restore-1');
      expect(restoredHabit, isNotNull);
      expect(restoredHabit?.isArchived, isFalse);
    });
  });
}
