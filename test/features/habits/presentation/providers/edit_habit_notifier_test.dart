import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/create_habit_state.dart';
import 'package:habit_tracker/features/habits/presentation/providers/edit_habit_notifier.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';

import 'create_habit_notifier_test.dart';

void main() {
  late MockHabitRepository repository;
  late ProviderContainer container;

  final now = DateTime.parse('2026-07-24T12:00:00.000Z');
  final testHabit = Habit(
    id: 'habit-edit-test-1',
    title: 'Read Books',
    description: 'Read 20 pages daily',
    icon: 'book',
    color: HabitColor.purple,
    frequency: HabitFrequency.daily,
    habitType: HabitType.numeric,
    targetCount: 20,
    createdAt: now,
    updatedAt: now,
    isArchived: false,
  );

  setUp(() {
    repository = MockHabitRepository();
    repository.savedHabits.add(testHabit);

    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('EditHabitNotifier Unit Tests', () {
    test('initial state pre-populates correctly from input habit', () {
      final state = container.read(editHabitProvider(testHabit));

      expect(state.habitId, equals('habit-edit-test-1'));
      expect(state.title, equals('Read Books'));
      expect(state.description, equals('Read 20 pages daily'));
      expect(state.icon, equals('book'));
      expect(state.color, equals(HabitColor.purple));
      expect(state.frequency, equals(HabitFrequency.daily));
      expect(state.habitType, equals(HabitType.numeric));
      expect(state.targetCount, equals(20));
      expect(state.isArchived, isFalse);
      expect(state.status, equals(FormSubmissionStatus.initial));
    });

    test('field updates modify state correctly', () {
      final notifier = container.read(editHabitProvider(testHabit).notifier);

      notifier.updateTitle('Read 50 pages');
      notifier.updateDescription('Read 50 pages of non-fiction');
      notifier.updateIcon('fire');
      notifier.updateColor(HabitColor.orange);
      notifier.updateFrequency(HabitFrequency.weekly);
      notifier.updateTargetCount(50);

      final state = container.read(editHabitProvider(testHabit));

      expect(state.title, equals('Read 50 pages'));
      expect(state.description, equals('Read 50 pages of non-fiction'));
      expect(state.icon, equals('fire'));
      expect(state.color, equals(HabitColor.orange));
      expect(state.frequency, equals(HabitFrequency.weekly));
      expect(state.targetCount, equals(50));
    });

    test('validation fails when title is empty', () {
      final notifier = container.read(editHabitProvider(testHabit).notifier);
      notifier.updateTitle('   ');

      final isValid = notifier.validate();
      final state = container.read(editHabitProvider(testHabit));

      expect(isValid, isFalse);
      expect(state.titleError, equals('Title cannot be empty'));
    });

    test('saveHabit persists updated habit to repository', () async {
      final notifier = container.read(editHabitProvider(testHabit).notifier);

      notifier.updateTitle('Updated Title');
      final success = await notifier.saveHabit();

      expect(success, isTrue);
      final state = container.read(editHabitProvider(testHabit));
      expect(state.status, equals(FormSubmissionStatus.success));

      final updatedInRepo = repository.savedHabits.firstWhere((h) => h.id == 'habit-edit-test-1');
      expect(updatedInRepo.title, equals('Updated Title'));
    });

    test('archiveHabit marks habit as archived', () async {
      final notifier = container.read(editHabitProvider(testHabit).notifier);

      final success = await notifier.archiveHabit();

      expect(success, isTrue);
      final state = container.read(editHabitProvider(testHabit));
      expect(state.isArchived, isTrue);

      final repoHabit = repository.savedHabits.firstWhere((h) => h.id == 'habit-edit-test-1');
      expect(repoHabit.isArchived, isTrue);
    });

    test('restoreHabit marks habit as active', () async {
      final archivedHabit = testHabit.copyWith(isArchived: true);
      repository.savedHabits.clear();
      repository.savedHabits.add(archivedHabit);

      final notifier = container.read(editHabitProvider(archivedHabit).notifier);

      final success = await notifier.restoreHabit();

      expect(success, isTrue);
      final state = container.read(editHabitProvider(archivedHabit));
      expect(state.isArchived, isFalse);

      final repoHabit = repository.savedHabits.firstWhere((h) => h.id == 'habit-edit-test-1');
      expect(repoHabit.isArchived, isFalse);
    });

    test('deleteHabit removes habit from repository', () async {
      final notifier = container.read(editHabitProvider(testHabit).notifier);

      final success = await notifier.deleteHabit();

      expect(success, isTrue);
      expect(repository.savedHabits.where((h) => h.id == 'habit-edit-test-1'), isEmpty);
    });
  });
}
