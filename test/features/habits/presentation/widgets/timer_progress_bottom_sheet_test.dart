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
    targetCount: 900, // 15 mins
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
    testWidgets('renders title, countdown clock starting at target, and Start button', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          TimerProgressBottomSheet(habit: habit),
        ),
      );

      expect(find.text('Meditation'), findsOneWidget);
      expect(find.text('15:00'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('+1 Min'), findsNothing);
      expect(find.text('Save Progress'), findsNothing);
    });

    testWidgets('starts, pauses, and resets countdown cleanly', (tester) async {
      await repository.createHabit(habit);

      await tester.pumpWidget(
        buildTestableWidget(
          TimerProgressBottomSheet(habit: habit),
        ),
      );

      // Tap Start
      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('14:59'), findsOneWidget);

      // Tap Pause
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      expect(find.text('Resume'), findsOneWidget);

      // Tap Reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('15:00'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('auto-completes when countdown reaches zero', (tester) async {
      final shortHabit = habit.copyWith(targetCount: 2);
      await repository.createHabit(shortHabit);

      await tester.pumpWidget(
        buildTestableWidget(
          TimerProgressBottomSheet(habit: shortHabit, targetDate: now),
        ),
      );

      await tester.tap(find.text('Start'));
      await tester.pump();

      // Tick 2 seconds
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Completed! 🎉'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(repository.logs.length, equals(1));
      expect(repository.logs.first.currentValue, equals(2));
    });
  });
}
