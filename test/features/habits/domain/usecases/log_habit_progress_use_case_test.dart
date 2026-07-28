import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/log_habit_progress_use_case.dart';

class InMemoryHabitRepository implements HabitRepository {
  final List<Habit> habits = [];
  final List<HabitLog> logs = [];

  final _habitsController = StreamController<List<Habit>>.broadcast();
  final _logsController = StreamController<List<HabitLog>>.broadcast();

  void _notify() {
    _habitsController.add(List.unmodifiable(habits));
    _logsController.add(List.unmodifiable(logs));
  }

  @override
  Future<void> createHabit(Habit habit) async {
    habits.add(habit);
    _notify();
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) habits[index] = habit;
    _notify();
  }

  @override
  Future<void> deleteHabit(String id) async {
    habits.removeWhere((h) => h.id == id);
    _notify();
  }

  @override
  Future<Habit?> getHabit(String id) async {
    final index = habits.indexWhere((h) => h.id == id);
    return index != -1 ? habits[index] : null;
  }

  @override
  Future<List<Habit>> getHabits() async => List.unmodifiable(habits);

  @override
  Stream<List<Habit>> watchHabits() async* {
    yield List.unmodifiable(habits);
    yield* _habitsController.stream;
  }

  @override
  Future<void> saveHabitLog(HabitLog log) async {
    final index = logs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      logs[index] = log;
    } else {
      logs.add(log);
    }
    _notify();
  }

  @override
  Future<void> saveHabitLogs(List<HabitLog> newLogs) async {
    for (final l in newLogs) {
      final index = logs.indexWhere((existing) => existing.id == l.id);
      if (index != -1) {
        logs[index] = l;
      } else {
        logs.add(l);
      }
    }
    _notify();
  }

  @override
  Future<void> logProgress(HabitLog log) => saveHabitLog(log);

  @override
  Future<HabitLog?> getHabitLog(String id) async {
    final index = logs.indexWhere((l) => l.id == id);
    return index != -1 ? logs[index] : null;
  }

  @override
  Future<List<HabitLog>> getHabitLogs(String habitId) async {
    return logs.where((l) => l.habitId == habitId).toList();
  }

  @override
  Future<List<HabitLog>> getLogsForHabit(String habitId) => getHabitLogs(habitId);

  @override
  Stream<List<HabitLog>> watchHabitLogs(String habitId) async* {
    yield logs.where((l) => l.habitId == habitId).toList();
    yield* _logsController.stream
        .map((_) => logs.where((l) => l.habitId == habitId).toList());
  }

  @override
  Future<void> deleteHabitLog(String id) async {
    logs.removeWhere((l) => l.id == id);
    _notify();
  }

  @override
  Future<void> deleteLog(String id) => deleteHabitLog(id);

  @override
  Stream<List<HabitLog>> watchTodayLogs(DateTime date) async* {
    yield getLogsForDateSync(date);
    yield* _logsController.stream.map((_) => getLogsForDateSync(date));
  }

  @override
  Future<List<HabitLog>> getLogsForDate(DateTime date) async =>
      getLogsForDateSync(date);

  List<HabitLog> getLogsForDateSync(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    return logs.where((l) {
      final logDate = DateTime(
          l.targetDate.year, l.targetDate.month, l.targetDate.day);
      return logDate.isAtSameMomentAs(target);
    }).toList();
  }

  @override
  Future<List<HabitLog>> getLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return logs.where((l) {
      if (habitIds != null && !habitIds.contains(l.habitId)) return false;
      return !l.targetDate.isBefore(start) && !l.targetDate.isAfter(end);
    }).toList();
  }

  @override
  Stream<List<HabitLog>> watchLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) async* {
    yield await getLogsForDateRange(startDate, endDate, habitIds: habitIds);
    yield* _logsController.stream.asyncMap(
      (_) => getLogsForDateRange(startDate, endDate, habitIds: habitIds),
    );
  }

  @override
  Future<List<HabitLog>> getLogsForHabits(List<String> habitIds) async {
    return logs.where((l) => habitIds.contains(l.habitId)).toList();
  }

  @override
  Future<List<HabitLog>> getLogsForHabitAndDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    return logs.where((l) {
      if (l.habitId != habitId) return false;
      return !l.targetDate.isBefore(start) && !l.targetDate.isAfter(end);
    }).toList();
  }

  void dispose() {
    _habitsController.close();
    _logsController.close();
  }
}

void main() {
  late InMemoryHabitRepository repository;
  late LogHabitProgressUseCase useCase;

  setUp(() {
    repository = InMemoryHabitRepository();
    useCase = LogHabitProgressUseCase(repository);
  });

  tearDown(() {
    repository.dispose();
  });

  group('LogHabitProgressUseCase', () {
    final now = DateTime(2026, 7, 28);
    final habitBoolean = Habit(
      id: 'h1',
      title: 'Read Book',
      habitType: HabitType.boolean,
      targetCount: 1,
      createdAt: now,
      updatedAt: now,
    );

    final habitNumeric = Habit(
      id: 'h2',
      title: 'Drink Water',
      habitType: HabitType.numeric,
      targetCount: 8,
      createdAt: now,
      updatedAt: now,
    );

    test('logs progress for a boolean habit as completed', () async {
      await repository.createHabit(habitBoolean);

      final result = await useCase.execute(
        habitId: 'h1',
        targetDate: now,
        status: HabitLogStatus.completed,
      );

      expect(result.habitId, equals('h1'));
      expect(result.status, equals(HabitLogStatus.completed));
      expect(result.currentValue, equals(1));
      expect(repository.logs.length, equals(1));
    });

    test('logs numeric progress with valueDelta incrementally', () async {
      await repository.createHabit(habitNumeric);

      final log1 = await useCase.execute(
        habitId: 'h2',
        targetDate: now,
        valueDelta: 3,
      );

      expect(log1.currentValue, equals(3));
      expect(log1.status, equals(HabitLogStatus.inProgress));

      final log2 = await useCase.execute(
        habitId: 'h2',
        targetDate: now,
        valueDelta: 5,
      );

      expect(log2.currentValue, equals(8));
      expect(log2.status, equals(HabitLogStatus.completed));
    });

    test('logs explicit value directly', () async {
      await repository.createHabit(habitNumeric);

      final result = await useCase.execute(
        habitId: 'h2',
        targetDate: now,
        value: 10,
      );

      expect(result.currentValue, equals(10));
      expect(result.status, equals(HabitLogStatus.completed));
    });

    test('throws ArgumentError when habit is not found', () async {
      expect(
        () => useCase.execute(habitId: 'non-existent', targetDate: now),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError when value is negative', () async {
      await repository.createHabit(habitNumeric);

      expect(
        () => useCase.execute(habitId: 'h2', targetDate: now, value: -5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('supports isFrozen flag for streak protection', () async {
      await repository.createHabit(habitBoolean);

      final result = await useCase.execute(
        habitId: 'h1',
        targetDate: now,
        status: HabitLogStatus.skipped,
        isFrozen: true,
      );

      expect(result.isFrozen, isTrue);
      expect(result.status, equals(HabitLogStatus.skipped));
    });
  });
}
