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
  Future<void> updateHabit(Habit habit) async {}

  @override
  Future<void> deleteHabit(String id) async {}

  @override
  Future<Habit?> getHabit(String id) async => null;

  @override
  Future<List<Habit>> getHabits() async => savedHabits;

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(savedHabits);

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
