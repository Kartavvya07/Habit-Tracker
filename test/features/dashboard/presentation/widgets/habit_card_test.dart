import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/dashboard/presentation/widgets/habit_card.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/numeric_progress_bottom_sheet.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/timer_progress_bottom_sheet.dart';

import '../../../habits/domain/usecases/log_habit_progress_use_case_test.dart';

void main() {
  late InMemoryHabitRepository repository;
  final now = DateTime(2026, 7, 25);

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
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
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
      expect(find.text('0 / 50'), findsOneWidget);
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
      expect(find.text('0m / 20 mins'), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
    });

    testWidgets('toggling boolean habit completes it and saves log to repository', (tester) async {
      final habit = Habit(
        id: 'habit-boolean',
        title: 'Read Book',
        habitType: HabitType.boolean,
        createdAt: now,
        updatedAt: now,
      );
      await repository.createHabit(habit);

      await tester.pumpWidget(buildTestableWidget(HabitCard(habit: habit)));

      await tester.tap(find.byTooltip('Mark Completed'));
      await tester.pumpAndSettle();

      expect(repository.logs.length, equals(1));
      expect(repository.logs.first.status, equals(HabitLogStatus.completed));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('tapping numeric habit card opens NumericProgressBottomSheet', (tester) async {
      final habit = Habit(
        id: 'habit-num',
        title: 'Water',
        habitType: HabitType.numeric,
        targetCount: 8,
        createdAt: now,
        updatedAt: now,
      );
      await repository.createHabit(habit);

      await tester.pumpWidget(buildTestableWidget(HabitCard(habit: habit)));

      await tester.tap(find.byType(HabitCard));
      await tester.pumpAndSettle();

      expect(find.byType(NumericProgressBottomSheet), findsOneWidget);
    });

    testWidgets('tapping timer habit card opens TimerProgressBottomSheet', (tester) async {
      final habit = Habit(
        id: 'habit-timer',
        title: 'Meditation',
        habitType: HabitType.timer,
        targetCount: 20,
        createdAt: now,
        updatedAt: now,
      );
      await repository.createHabit(habit);

      await tester.pumpWidget(buildTestableWidget(HabitCard(habit: habit)));

      await tester.tap(find.byType(HabitCard));
      await tester.pumpAndSettle();

      expect(find.byType(TimerProgressBottomSheet), findsOneWidget);
    });

    testWidgets('triggers custom onTap callback when provided', (tester) async {
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

    testWidgets('rolls back UI state and displays SnackBar when repository throws error', (tester) async {
      final failingRepository = FailingHabitRepository();
      final habit = Habit(
        id: 'habit-failing',
        title: 'Floss Teeth',
        habitType: HabitType.boolean,
        createdAt: now,
        updatedAt: now,
      );
      await failingRepository.createHabit(habit);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitRepositoryProvider.overrideWithValue(failingRepository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: HabitCard(habit: habit),
            ),
          ),
        ),
      );

      // Initial state is uncompleted
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

      // Tap completion toggle
      await tester.tap(find.byTooltip('Mark Completed'));
      await tester.pumpAndSettle();

      // Verify error SnackBar is displayed
      expect(find.textContaining('Failed to update habit progress'), findsOneWidget);

      // Verify UI rolled back and habit remains UNCOMPLETED
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);

      failingRepository.dispose();
    });
  });
}

class FailingHabitRepository extends InMemoryHabitRepository {
  @override
  Future<void> saveHabitLog(HabitLog log) async {
    throw Exception('Database write error');
  }
}

