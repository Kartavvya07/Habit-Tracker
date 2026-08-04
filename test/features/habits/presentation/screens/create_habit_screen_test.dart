import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/router.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/screens/create_habit_screen.dart';

import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';
import 'package:habit_tracker/features/settings/presentation/providers/vacation_mode_provider.dart';

import '../../../settings/presentation/providers/vacation_mode_provider_test.dart';

class FakeHabitRepository implements HabitRepository {
  final List<Habit> savedHabits = [];

  @override
  Future<void> createHabit(Habit habit) async {
    savedHabits.add(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = savedHabits.indexWhere((h) => h.id == habit.id);
    if (index != -1) savedHabits[index] = habit;
  }

  @override
  Future<void> archiveHabit(String id) async {
    final index = savedHabits.indexWhere((h) => h.id == id);
    if (index != -1) savedHabits[index] = savedHabits[index].copyWith(isArchived: true);
  }

  @override
  Future<void> restoreHabit(String id) async {
    final index = savedHabits.indexWhere((h) => h.id == id);
    if (index != -1) savedHabits[index] = savedHabits[index].copyWith(isArchived: false);
  }

  @override
  Future<void> deleteHabit(String id) async {
    savedHabits.removeWhere((h) => h.id == id);
  }

  @override
  Future<Habit?> getHabit(String id) async => null;

  @override
  Future<List<Habit>> getHabits() async => savedHabits;

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(savedHabits);

  @override
  Future<List<Habit>> getActiveHabits() async => savedHabits.where((h) => !h.isArchived).toList();

  @override
  Stream<List<Habit>> watchActiveHabits() => Stream.value(savedHabits.where((h) => !h.isArchived).toList());

  @override
  Future<List<Habit>> getArchivedHabits() async => savedHabits.where((h) => h.isArchived).toList();

  @override
  Stream<List<Habit>> watchArchivedHabits() => Stream.value(savedHabits.where((h) => h.isArchived).toList());

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

  @override
  Future<void> saveHabitLogs(List<HabitLog> logs) async {}

  @override
  Future<void> logProgress(HabitLog log) async {}

  @override
  Future<List<HabitLog>> getLogsForHabit(String habitId) async => [];

  @override
  Future<void> deleteLog(String id) async {}

  @override
  Stream<List<HabitLog>> watchTodayLogs(DateTime date) => Stream.value([]);

  @override
  Future<List<HabitLog>> getLogsForDate(DateTime date) async => [];

  @override
  Future<List<HabitLog>> getLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) async =>
      [];

  @override
  Stream<List<HabitLog>> watchLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) =>
      Stream.value([]);

  @override
  Future<List<HabitLog>> getLogsForHabits(List<String> habitIds) async => [];

  @override
  Future<List<HabitLog>> getLogsForHabitAndDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async =>
      [];
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
        vacationModeRepositoryProvider.overrideWithValue(FakeVacationModeRepository()),
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
      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
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
