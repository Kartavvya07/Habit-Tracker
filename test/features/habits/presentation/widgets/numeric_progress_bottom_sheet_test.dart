import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/numeric_progress_bottom_sheet.dart';

import '../../domain/usecases/log_habit_progress_use_case_test.dart';

void main() {
  late InMemoryHabitRepository repository;
  final now = DateTime(2026, 7, 28);
  final habit = Habit(
    id: 'h-numeric',
    title: 'Water Glasses',
    habitType: HabitType.numeric,
    targetCount: 8,
    color: HabitColor.blue,
    frequency: HabitFrequency.daily,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    repository = InMemoryHabitRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('NumericProgressBottomSheet Widget Tests', () {
    testWidgets('renders header, target ratio, slider, stepper and chips correctly', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          NumericProgressBottomSheet(habit: habit),
        ),
      );

      expect(find.text('Water Glasses'), findsOneWidget);
      expect(find.text('0 / 8'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Save Progress'), findsOneWidget);
    });

    testWidgets('increments and decrements value via stepper and chips with Goal Reached badge', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          NumericProgressBottomSheet(habit: habit),
        ),
      );

      expect(find.text('0 / 8'), findsOneWidget);

      await tester.tap(find.byTooltip('Increment'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 8'), findsOneWidget);

      await tester.tap(find.text('Target'));
      await tester.pumpAndSettle();
      expect(find.text('8 / 8'), findsOneWidget);
      expect(find.text('Goal Reached 🎉'), findsOneWidget);

      await tester.tap(find.byTooltip('Decrement'));
      await tester.pumpAndSettle();
      expect(find.text('7 / 8'), findsOneWidget);
      expect(find.text('Goal Reached 🎉'), findsNothing);
    });

    testWidgets('submits progress successfully and persists log to repository', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          NumericProgressBottomSheet(habit: habit, targetDate: now),
        ),
      );

      await tester.tap(find.text('+5'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Progress'));
      await tester.pumpAndSettle();

      expect(repository.logs.length, equals(1));
      expect(repository.logs.first.currentValue, equals(5));
      expect(repository.logs.first.habitId, equals('h-numeric'));
    });
  });
}
