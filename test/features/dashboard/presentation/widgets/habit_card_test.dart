import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/dashboard/presentation/widgets/habit_card.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';

void main() {
  final now = DateTime(2026, 7, 25);

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('HabitCard Widget Tests', () {
    testWidgets('renders boolean habit card correctly', (tester) async {
      final habit = Habit(
        id: 'habit-1',
        title: 'Morning Water',
        description: 'Drink 1 glass of water',
        icon: 'water_drop',
        color: HabitColor.blue,
        frequency: HabitFrequency.daily,
        habitType: HabitType.boolean,
        targetCount: 1,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestableWidget(HabitCard(habit: habit)));

      expect(find.text('Morning Water'), findsOneWidget);
      expect(find.text('Drink 1 glass of water'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Yes/No'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    });

    testWidgets('renders numeric habit card with target count correctly', (tester) async {
      final habit = Habit(
        id: 'habit-2',
        title: 'Pushups',
        description: 'Daily exercise',
        icon: 'fitness_center',
        color: HabitColor.orange,
        frequency: HabitFrequency.daily,
        habitType: HabitType.numeric,
        targetCount: 50,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestableWidget(HabitCard(habit: habit)));

      expect(find.text('Pushups'), findsOneWidget);
      expect(find.text('Numeric'), findsOneWidget);
      expect(find.text('Target: 50'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('renders timer habit card with target minutes correctly', (tester) async {
      final habit = Habit(
        id: 'habit-3',
        title: 'Meditation',
        description: 'Mindfulness session',
        icon: 'self_improvement',
        color: HabitColor.purple,
        frequency: HabitFrequency.daily,
        habitType: HabitType.timer,
        targetCount: 20,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(buildTestableWidget(HabitCard(habit: habit)));

      expect(find.text('Meditation'), findsOneWidget);
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Target: 20 mins'), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;
      final habit = Habit(
        id: 'habit-4',
        title: 'Reading',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          HabitCard(
            habit: habit,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(HabitCard));
      expect(tapped, isTrue);
    });
  });
}
