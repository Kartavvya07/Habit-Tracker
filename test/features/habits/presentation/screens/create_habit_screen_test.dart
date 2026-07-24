import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/router.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/screens/create_habit_screen.dart';

class FakeHabitRepository implements HabitRepository {
  final List<Habit> savedHabits = [];

  @override
  Future<void> createHabit(Habit habit) async {
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
}

void main() {
  late FakeHabitRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeHabitRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(fakeRepository),
      ],
      child: MaterialApp.router(
        routerConfig: goRouter,
      ),
    );
  }

  group('CreateHabitScreen Widget Tests', () {
    testWidgets('renders all form components correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: CreateHabitScreen(),
          ),
        ),
      );

      expect(find.text('Create New Habit'), findsOneWidget);
      expect(find.text('Habit Title'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Habit Type'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Icon'), findsOneWidget);
      expect(find.text('Save Habit'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays validation error when saving empty title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: CreateHabitScreen(),
          ),
        ),
      );

      await tester.ensureVisible(find.text('Save Habit'));
      await tester.tap(find.text('Save Habit'));
      await tester.pumpAndSettle();

      expect(find.text('Title cannot be empty'), findsOneWidget);
      expect(fakeRepository.savedHabits, isEmpty);
    });

    testWidgets('navigates from Dashboard to CreateHabitScreen via FAB', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Habit Tracker'), findsOneWidget);
      expect(find.text('Create Habit'), findsOneWidget);

      await tester.tap(find.text('Create Habit'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Habit'), findsOneWidget);
    });

    testWidgets('fills form and saves habit successfully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: const MaterialApp(
            home: CreateHabitScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Morning Run');
      await tester.enterText(find.byType(TextField).at(1), '5km run in park');

      await tester.ensureVisible(find.text('Save Habit'));
      await tester.tap(find.text('Save Habit'));
      await tester.pumpAndSettle();

      expect(fakeRepository.savedHabits.length, equals(1));
      expect(fakeRepository.savedHabits.first.title, equals('Morning Run'));
      expect(fakeRepository.savedHabits.first.description, equals('5km run in park'));
    });
  });
}
