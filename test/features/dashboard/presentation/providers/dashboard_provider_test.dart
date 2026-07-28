import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:habit_tracker/features/dashboard/presentation/providers/dashboard_state.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';

import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';

class MockStreamHabitRepository implements HabitRepository {
  final StreamController<List<Habit>> _controller =
      StreamController<List<Habit>>.broadcast();

  StreamController<List<Habit>> get controller => _controller;

  void emitHabits(List<Habit> habits) {
    _controller.add(habits);
  }

  void emitError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  void dispose() {
    _controller.close();
  }

  @override
  Stream<List<Habit>> watchHabits() => _controller.stream;

  @override
  Future<void> createHabit(Habit habit) async {}

  @override
  Future<void> updateHabit(Habit habit) async {}

  @override
  Future<void> deleteHabit(String id) async {}

  @override
  Future<Habit?> getHabit(String id) async => null;

  @override
  Future<List<Habit>> getHabits() async => [];

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
}

void main() {
  late MockStreamHabitRepository mockRepository;
  late ProviderContainer container;

  final testHabit1 = Habit(
    id: 'habit-1',
    title: 'Morning Meditation',
    description: '10 minutes of mindfulness',
    icon: 'self_improvement',
    color: HabitColor.purple,
    frequency: HabitFrequency.daily,
    habitType: HabitType.boolean,
    targetCount: 1,
    createdAt: DateTime(2026, 7, 25, 10, 0),
    updatedAt: DateTime(2026, 7, 25, 10, 0),
  );

  final testHabit2 = Habit(
    id: 'habit-2',
    title: 'Read Books',
    description: 'Read 20 pages',
    icon: 'book',
    color: HabitColor.blue,
    frequency: HabitFrequency.daily,
    habitType: HabitType.numeric,
    targetCount: 20,
    createdAt: DateTime(2026, 7, 24, 10, 0),
    updatedAt: DateTime(2026, 7, 24, 10, 0),
  );

  setUp(() {
    mockRepository = MockStreamHabitRepository();
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    mockRepository.dispose();
  });

  group('DashboardState Equality Tests', () {
    test('DashboardLoading instances are equal', () {
      expect(const DashboardLoading(), equals(const DashboardLoading()));
    });

    test('DashboardEmpty instances are equal', () {
      expect(const DashboardEmpty(), equals(const DashboardEmpty()));
    });

    test('DashboardLoaded instances with identical lists are equal', () {
      expect(
        DashboardLoaded([testHabit1, testHabit2]),
        equals(DashboardLoaded([testHabit1, testHabit2])),
      );
    });

    test('DashboardLoaded instances with different lists are not equal', () {
      expect(
        DashboardLoaded([testHabit1]),
        isNot(equals(DashboardLoaded([testHabit2]))),
      );
    });

    test('DashboardError instances with same parameters are equal', () {
      final exception = Exception('Failed to load');
      expect(
        DashboardError('Failed to load', exception),
        equals(DashboardError('Failed to load', exception)),
      );
    });
  });

  group('DashboardProvider Tests', () {
    test('initial state before stream emission is DashboardLoading', () {
      final state = container.read(dashboardProvider);
      expect(state, isA<DashboardLoading>());
    });

    test('emits DashboardEmpty when repository stream emits an empty list',
        () async {
      final emittedStates = <DashboardState>[];
      container.listen(
        dashboardProvider,
        (previous, next) => emittedStates.add(next),
        fireImmediately: true,
      );

      expect(emittedStates.first, isA<DashboardLoading>());

      mockRepository.emitHabits([]);
      await pumpEventQueue();

      expect(emittedStates.last, isA<DashboardEmpty>());
      expect(container.read(dashboardProvider), equals(const DashboardEmpty()));
    });

    test('emits DashboardLoaded when repository stream emits habits',
        () async {
      final emittedStates = <DashboardState>[];
      container.listen(
        dashboardProvider,
        (previous, next) => emittedStates.add(next),
        fireImmediately: true,
      );

      mockRepository.emitHabits([testHabit1, testHabit2]);
      await pumpEventQueue();

      final currentState = container.read(dashboardProvider);
      expect(currentState, isA<DashboardLoaded>());
      final loadedState = currentState as DashboardLoaded;
      expect(loadedState.habits, equals([testHabit1, testHabit2]));
      expect(loadedState.habits.first, equals(testHabit1));
    });

    test('emits DashboardError when repository stream emits an error',
        () async {
      final emittedStates = <DashboardState>[];
      container.listen(
        dashboardProvider,
        (previous, next) => emittedStates.add(next),
        fireImmediately: true,
      );

      final testException = Exception('Database connection dropped');
      mockRepository.emitError(testException);
      await pumpEventQueue();

      final currentState = container.read(dashboardProvider);
      expect(currentState, isA<DashboardError>());
      final errorState = currentState as DashboardError;
      expect(errorState.message, contains('Database connection dropped'));
      expect(errorState.error, equals(testException));
    });

    test('reacts automatically when repository stream emits new data over time',
        () async {
      final emittedStates = <DashboardState>[];
      container.listen(
        dashboardProvider,
        (previous, next) => emittedStates.add(next),
        fireImmediately: true,
      );

      // State 1: Loading
      expect(emittedStates.last, isA<DashboardLoading>());

      // State 2: Stream emits empty list -> DashboardEmpty
      mockRepository.emitHabits([]);
      await pumpEventQueue();
      expect(emittedStates.last, isA<DashboardEmpty>());

      // State 3: Habit added -> Stream emits list with testHabit1 -> DashboardLoaded
      mockRepository.emitHabits([testHabit1]);
      await pumpEventQueue();
      expect(emittedStates.last, equals(DashboardLoaded([testHabit1])));

      // State 4: Second habit added -> Stream emits list with 2 habits
      mockRepository.emitHabits([testHabit1, testHabit2]);
      await pumpEventQueue();
      expect(emittedStates.last, equals(DashboardLoaded([testHabit1, testHabit2])));

      expect(emittedStates.length, equals(4));
    });

    test('preserves repository order without re-sorting', () async {
      container.listen(dashboardProvider, (_, __) {});
      // Repository stream emits habits in specific order
      mockRepository.emitHabits([testHabit1, testHabit2]);
      await pumpEventQueue();

      final state = container.read(dashboardProvider) as DashboardLoaded;
      expect(state.habits[0], equals(testHabit1));
      expect(state.habits[1], equals(testHabit2));
    });
  });
}
