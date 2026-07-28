import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/timer_progress_bottom_sheet.dart';

import '../../domain/usecases/log_habit_progress_use_case_test.dart';

void main() {
  late InMemoryHabitRepository repository;
  final now = DateTime(2026, 7, 28);
  final habit = Habit(
    id: 'h-timer',
    title: 'Meditation',
    habitType: HabitType.timer,
    targetCount: 15,
    color: HabitColor.purple,
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

  group('TimerProgressBottomSheet Widget Tests', () {
    testWidgets('renders title, target minutes, timer display and quick chips', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          TimerProgressBottomSheet(habit: habit),
        ),
      );

      expect(find.text('Meditation'), findsOneWidget);
      expect(find.text('Target: 15 mins'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('+1 Min'), findsOneWidget);
      expect(find.text('+5 Mins'), findsOneWidget);
      expect(find.text('Save Progress'), findsOneWidget);
    });

    testWidgets('adds minutes via quick chips and resets timer', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          TimerProgressBottomSheet(habit: habit),
        ),
      );

      await tester.tap(find.text('+5 Mins'));
      await tester.pumpAndSettle();
      expect(find.text('05:00'), findsOneWidget);

      await tester.tap(find.byTooltip('Reset Timer'));
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('submits progress and saves log to repository', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          TimerProgressBottomSheet(habit: habit, targetDate: now),
        ),
      );

      await tester.tap(find.text('+10 Mins'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Progress'));
      await tester.pumpAndSettle();

      expect(repository.logs.length, equals(1));
      expect(repository.logs.first.currentValue, equals(10));
      expect(repository.logs.first.habitId, equals('h-timer'));
    });
  });
}
