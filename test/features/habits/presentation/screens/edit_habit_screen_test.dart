import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/screens/edit_habit_screen.dart';

import 'create_habit_screen_test.dart';

void main() {
  late FakeHabitRepository repository;

  final now = DateTime.parse('2026-07-24T12:00:00.000Z');
  final testHabit = Habit(
    id: 'habit-widget-test-1',
    title: 'Daily Run',
    description: 'Run 5km every morning',
    icon: 'run',
    color: HabitColor.red,
    frequency: HabitFrequency.daily,
    habitType: HabitType.numeric,
    targetCount: 5,
    createdAt: now,
    updatedAt: now,
    isArchived: false,
  );

  setUp(() {
    repository = FakeHabitRepository();
    repository.savedHabits.add(testHabit);
  });

  Widget createWidgetUnderTest(Habit habit) {
    return ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: EditHabitScreen(habit: habit),
      ),
    );
  }

  group('EditHabitScreen Widget Tests', () {
    testWidgets('renders pre-populated form components correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testHabit));
      await tester.pumpAndSettle();

      expect(find.text('Edit Habit'), findsOneWidget);
      expect(find.text('Daily Run'), findsOneWidget);
      expect(find.text('Run 5km every morning'), findsOneWidget);
      expect(find.text('Update Habit'), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('editing fields and clicking Update Habit saves changes', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testHabit));
      await tester.pumpAndSettle();

      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Evening Run');
      await tester.pumpAndSettle();

      final updateButton = find.text('Update Habit');
      await tester.ensureVisible(updateButton);
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      expect(repository.savedHabits.first.title, equals('Evening Run'));
    });

    testWidgets('tapping archive button toggles archive state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testHabit));
      await tester.pumpAndSettle();

      final archiveButton = find.byIcon(Icons.archive_outlined);
      await tester.tap(archiveButton);
      await tester.pumpAndSettle();

      expect(repository.savedHabits.first.isArchived, isTrue);
    });

    testWidgets('tapping delete button shows confirmation dialog and deletes on confirm', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testHabit));
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Delete Habit?'), findsOneWidget);
      expect(find.text('This action will permanently remove this habit and all associated execution logs. This action cannot be undone.'), findsOneWidget);

      final confirmDeleteButton = find.widgetWithText(FilledButton, 'Delete');
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      expect(repository.savedHabits.where((h) => h.id == 'habit-widget-test-1'), isEmpty);
    });
  });
}
