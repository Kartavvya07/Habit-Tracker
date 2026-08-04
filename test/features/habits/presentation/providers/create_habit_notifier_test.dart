import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/presentation/providers/create_habit_notifier.dart';
import 'package:habit_tracker/features/habits/presentation/providers/create_habit_state.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';

import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';

class MockHabitRepository implements HabitRepository {
  final List<Habit> savedHabits = [];
  bool shouldThrow = false;

  @override
  Future<void> createHabit(Habit habit) async {
    if (shouldThrow) {
      throw Exception('Database failure');
    }
    savedHabits.add(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = savedHabits.indexWhere((h) => h.id == habit.id);
    if (index != -1) savedHabits[index] = habit;
  }

  @override
  Future<void> archiveHabit(String id) async {
    final index = savedHabits.indexWhere((h) => h.id == id);
    if (index != -1) savedHabits[index] = savedHabits[index].copyWith(isArchived: true);
  }

  @override
  Future<void> restoreHabit(String id) async {
    final index = savedHabits.indexWhere((h) => h.id == id);
    if (index != -1) savedHabits[index] = savedHabits[index].copyWith(isArchived: false);
  }

  @override
  Future<void> deleteHabit(String id) async {
    savedHabits.removeWhere((h) => h.id == id);
  }

  @override
  Future<Habit?> getHabit(String id) async => null;

  @override
  Future<List<Habit>> getHabits() async => savedHabits;

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(savedHabits);

  @override
  Future<List<Habit>> getActiveHabits() async => savedHabits.where((h) => !h.isArchived).toList();

  @override
  Stream<List<Habit>> watchActiveHabits() => Stream.value(savedHabits.where((h) => !h.isArchived).toList());

  @override
  Future<List<Habit>> getArchivedHabits() async => savedHabits.where((h) => h.isArchived).toList();

  @override
  Stream<List<Habit>> watchArchivedHabits() => Stream.value(savedHabits.where((h) => h.isArchived).toList());

  @override
  Future<void> saveHabitLog(HabitLog log) async {}

  @override
  Future<HabitLog?> getHabitLog(String id) async => null;

  @override
  Future<List<HabitLog>> getHabitLogs(String habitId) async => [];

  @override
  Stream<List<HabitLog>> watchHabitLogs(String habitId) => Stream.value([]);

  @override
  Future<void> deleteHabitLog(String id) async {}

  @override
  Future<void> saveHabitLogs(List<HabitLog> logs) async {}

  @override
  Future<void> logProgress(HabitLog log) async {}

  @override
  Future<List<HabitLog>> getLogsForHabit(String habitId) async => [];

  @override
  Future<void> deleteLog(String id) async {}

  @override
  Stream<List<HabitLog>> watchTodayLogs(DateTime date) => Stream.value([]);

  @override
  Future<List<HabitLog>> getLogsForDate(DateTime date) async => [];

  @override
  Future<List<HabitLog>> getLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) async =>
      [];

  @override
  Stream<List<HabitLog>> watchLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) =>
      Stream.value([]);

  @override
  Future<List<HabitLog>> getLogsForHabits(List<String> habitIds) async => [];

  @override
  Future<List<HabitLog>> getLogsForHabitAndDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async =>
      [];
}


void main() {
  late MockHabitRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockHabitRepository();
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CreateHabitNotifier Tests', () {
    test('initial state is correct', () {
      final state = container.read(createHabitProvider);
      expect(state.title, isEmpty);
      expect(state.description, isEmpty);
      expect(state.icon, equals('check'));
      expect(state.color, equals(HabitColor.blue));
      expect(state.frequency, equals(HabitFrequency.daily));
      expect(state.habitType, equals(HabitType.boolean));
      expect(state.targetCount, equals(1));
      expect(state.status, equals(FormSubmissionStatus.initial));
    });

    test('field updates modify state correctly', () {
      final notifier = container.read(createHabitProvider.notifier);

      notifier.updateTitle('Drink Water');
      notifier.updateDescription('8 glasses a day');
      notifier.updateColor(HabitColor.teal);
      notifier.updateFrequency(HabitFrequency.weekly);
      notifier.updateHabitType(HabitType.numeric);
      notifier.updateTargetCount(8);
      notifier.updateIcon('water_drop');

      final state = container.read(createHabitProvider);
      expect(state.title, equals('Drink Water'));
      expect(state.description, equals('8 glasses a day'));
      expect(state.color, equals(HabitColor.teal));
      expect(state.frequency, equals(HabitFrequency.weekly));
      expect(state.habitType, equals(HabitType.numeric));
      expect(state.targetCount, equals(8));
      expect(state.icon, equals('water_drop'));
    });

    test('validation fails when title is empty', () async {
      final notifier = container.read(createHabitProvider.notifier);

      final success = await notifier.saveHabit();
      final state = container.read(createHabitProvider);

      expect(success, isFalse);
      expect(state.titleError, equals('Title cannot be empty'));
      expect(mockRepository.savedHabits, isEmpty);
    });

    test('validation fails when target count is 0 for numeric habit', () async {
      final notifier = container.read(createHabitProvider.notifier);
      notifier.updateTitle('Run');
      notifier.updateHabitType(HabitType.numeric);
      notifier.updateTargetCount(0);

      final success = await notifier.saveHabit();
      final state = container.read(createHabitProvider);

      expect(success, isFalse);
      expect(
          state.targetCountError, equals('Target count must be greater than 0'));
      expect(mockRepository.savedHabits, isEmpty);
    });

    test('successful saveHabit persists habit to repository', () async {
      final notifier = container.read(createHabitProvider.notifier);

      notifier.updateTitle('Read Book');
      notifier.updateDescription('20 pages daily');
      notifier.updateColor(HabitColor.purple);
      notifier.updateIcon('book');

      final success = await notifier.saveHabit();
      final state = container.read(createHabitProvider);

      expect(success, isTrue);
      expect(state.status, equals(FormSubmissionStatus.success));
      expect(mockRepository.savedHabits.length, equals(1));
      expect(mockRepository.savedHabits.first.title, equals('Read Book'));
      expect(mockRepository.savedHabits.first.color, equals(HabitColor.purple));
    });

    test('handles database exception gracefully during save', () async {
      mockRepository.shouldThrow = true;
      final notifier = container.read(createHabitProvider.notifier);

      notifier.updateTitle('Yoga');
      final success = await notifier.saveHabit();
      final state = container.read(createHabitProvider);

      expect(success, isFalse);
      expect(state.status, equals(FormSubmissionStatus.failure));
      expect(state.errorMessage, contains('Database failure'));
    });
  });
}
