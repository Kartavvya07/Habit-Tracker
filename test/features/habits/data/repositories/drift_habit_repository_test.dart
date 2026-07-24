import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/features/habits/data/repositories/drift_habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';

void main() {
  late AppDatabase db;
  late DriftHabitRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftHabitRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  final now = DateTime.parse('2026-07-24T12:00:00.000Z');
  final testHabit = Habit(
    id: 'habit-1',
    title: 'Read Books',
    description: 'Read 20 pages',
    icon: 'book',
    color: HabitColor.purple,
    frequency: HabitFrequency.daily,
    habitType: HabitType.numeric,
    targetCount: 20,
    createdAt: now,
    updatedAt: now,
    isArchived: false,
  );

  group('DriftHabitRepository Tests', () {
    test('createHabit and getHabit retrieve habit accurately', () async {
      await repository.createHabit(testHabit);
      final retrieved = await repository.getHabit('habit-1');

      expect(retrieved, isNotNull);
      expect(retrieved, equals(testHabit));
    });

    test('updateHabit updates existing database record', () async {
      await repository.createHabit(testHabit);
      final updatedHabit = testHabit.copyWith(
        title: 'Read 30 pages',
        targetCount: 30,
      );

      await repository.updateHabit(updatedHabit);
      final retrieved = await repository.getHabit('habit-1');

      expect(retrieved?.title, equals('Read 30 pages'));
      expect(retrieved?.targetCount, equals(30));
    });

    test('deleteHabit removes habit from database', () async {
      await repository.createHabit(testHabit);
      await repository.deleteHabit('habit-1');

      final retrieved = await repository.getHabit('habit-1');
      expect(retrieved, isNull);
    });

    test('watchHabits emits live stream of habits', () async {
      expect(repository.watchHabits(), emitsThrough([testHabit]));
      await repository.createHabit(testHabit);
    });
  });
}
