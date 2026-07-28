import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/features/habits/data/repositories/drift_habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
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

    group('watchHabits Stream', () {
      test('emits empty list when database is empty', () async {
        final habits = await repository.watchHabits().first;
        expect(habits, isEmpty);
      });

      test('emits single habit when one habit exists in database', () async {
        await repository.createHabit(testHabit);
        final habits = await repository.watchHabits().first;
        expect(habits, equals([testHabit]));
      });

      test('emits multiple habits when multiple exist in database', () async {
        final secondHabit = testHabit.copyWith(
          id: 'habit-2',
          title: 'Drink Water',
        );
        await repository.createHabit(testHabit);
        await repository.createHabit(secondHabit);

        final habits = await repository.watchHabits().first;
        expect(habits.length, equals(2));
        expect(habits, containsAll([testHabit, secondHabit]));
      });

      test('automatically emits updated list after habit insert', () async {
        final secondHabit = testHabit.copyWith(
          id: 'habit-2',
          title: 'Exercise',
          createdAt: now.add(const Duration(hours: 1)),
        );

        final emissions = <List<Habit>>[];
        final subscription = repository.watchHabits().listen(emissions.add);

        // 1. Allow initial emission (empty list)
        await Future<void>.delayed(Duration.zero);
        expect(emissions.length, 1);
        expect(emissions.last, isEmpty);

        // 2. First insert triggers update event
        await repository.createHabit(testHabit);
        await Future<void>.delayed(Duration.zero);
        expect(emissions.length, 2);
        expect(emissions.last, equals([testHabit]));

        // 3. Second insert (newer timestamp) triggers update event with newest first
        await repository.createHabit(secondHabit);
        await Future<void>.delayed(Duration.zero);
        expect(emissions.length, 3);
        expect(emissions.last, equals([secondHabit, testHabit]));

        await subscription.cancel();
      });

      test('orders habits by createdAt DESC (newest first)', () async {
        final olderHabit = testHabit.copyWith(
          id: 'habit-older',
          title: 'Older Habit',
          createdAt: DateTime.parse('2026-01-01T10:00:00.000Z'),
        );
        final newerHabit = testHabit.copyWith(
          id: 'habit-newer',
          title: 'Newer Habit',
          createdAt: DateTime.parse('2026-07-25T10:00:00.000Z'),
        );

        // Insert older habit first, then newer habit
        await repository.createHabit(olderHabit);
        await repository.createHabit(newerHabit);

        final habits = await repository.watchHabits().first;
        expect(habits.length, equals(2));
        expect(habits[0].id, equals('habit-newer'));
        expect(habits[1].id, equals('habit-older'));
      });

      test('correctly maps database row fields to Habit domain entity', () async {
        await repository.createHabit(testHabit);
        final habits = await repository.watchHabits().first;
        final habit = habits.single;

        expect(habit.id, equals('habit-1'));
        expect(habit.title, equals('Read Books'));
        expect(habit.description, equals('Read 20 pages'));
        expect(habit.icon, equals('book'));
        expect(habit.color, equals(HabitColor.purple));
        expect(habit.frequency, equals(HabitFrequency.daily));
        expect(habit.habitType, equals(HabitType.numeric));
        expect(habit.targetCount, equals(20));
        expect(habit.createdAt, equals(now));
        expect(habit.updatedAt, equals(now));
        expect(habit.isArchived, isFalse);
      });
    });

    group('DriftHabitRepository HabitLog Persistence Tests', () {
      final testLog = HabitLog(
        id: 'log-repo-1',
        habitId: 'habit-1',
        targetDate: now,
        status: HabitLogStatus.completed,
        currentValue: 20,
        isFrozen: false,
      );

      setUp(() async {
        await repository.createHabit(testHabit);
      });

      test('saveHabitLog and getHabitLog save and retrieve domain log', () async {
        await repository.saveHabitLog(testLog);
        final retrieved = await repository.getHabitLog('log-repo-1');

        expect(retrieved, isNotNull);
        expect(retrieved, equals(testLog));
      });

      test('getHabitLogs returns all logs for specific habit', () async {
        final secondLog = testLog.copyWith(
          id: 'log-repo-2',
          targetDate: now.add(const Duration(days: 1)),
          status: HabitLogStatus.skipped,
        );

        await repository.saveHabitLog(testLog);
        await repository.saveHabitLog(secondLog);

        final logs = await repository.getHabitLogs('habit-1');
        expect(logs.length, equals(2));
        expect(logs, containsAll([testLog, secondLog]));
      });

      test('watchHabitLogs emits reactive updates', () async {
        final emissions = <List<HabitLog>>[];
        final subscription = repository.watchHabitLogs('habit-1').listen(emissions.add);

        await Future<void>.delayed(Duration.zero);
        expect(emissions.last, isEmpty);

        await repository.saveHabitLog(testLog);
        await Future<void>.delayed(Duration.zero);

        expect(emissions.last.length, equals(1));
        expect(emissions.last.single, equals(testLog));

        await subscription.cancel();
      });

      test('deleteHabitLog removes log from repository', () async {
        await repository.saveHabitLog(testLog);
        await repository.deleteHabitLog('log-repo-1');

        final retrieved = await repository.getHabitLog('log-repo-1');
        expect(retrieved, isNull);
      });
    });
  });
}
