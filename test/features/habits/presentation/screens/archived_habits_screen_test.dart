import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/screens/archived_habits_screen.dart';

import 'create_habit_screen_test.dart';

void main() {
  late FakeHabitRepository repository;

  final now = DateTime.parse('2026-07-24T12:00:00.000Z');
  final testArchivedHabit = Habit(
    id: 'archived-habit-1',
    title: 'Old Meditation Routine',
    description: '10 mins daily',
    icon: 'meditation',
    color: HabitColor.blue,
    frequency: HabitFrequency.daily,
    habitType: HabitType.boolean,
    targetCount: 1,
    createdAt: now,
    updatedAt: now,
    isArchived: true,
  );

  setUp(() {
    repository = FakeHabitRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: ArchivedHabitsScreen(),
      ),
    );
  }

  group('ArchivedHabitsScreen Widget Tests', () {
    testWidgets('renders empty view when no archived habits exist', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Archived Habits'), findsOneWidget);
      expect(find.text('No archived habits'), findsOneWidget);
    });

    testWidgets('renders list of archived habits accurately', (tester) async {
      repository.savedHabits.add(testArchivedHabit);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Old Meditation Routine'), findsOneWidget);
      expect(find.text('10 mins daily'), findsOneWidget);
      expect(find.byIcon(Icons.unarchive), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('tapping restore button restores habit to active state', (tester) async {
      repository.savedHabits.add(testArchivedHabit);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final restoreButton = find.byIcon(Icons.unarchive);
      await tester.tap(restoreButton);
      await tester.pumpAndSettle();

      expect(repository.savedHabits.first.isArchived, isFalse);
    });

    testWidgets('tapping delete button opens confirmation dialog and deletes permanently', (tester) async {
      repository.savedHabits.add(testArchivedHabit);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete_forever);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Delete Permanently?'), findsOneWidget);

      final confirmDeleteButton = find.widgetWithText(FilledButton, 'Delete Permanently');
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      expect(repository.savedHabits.where((h) => h.id == 'archived-habit-1'), isEmpty);
    });
  });
}
