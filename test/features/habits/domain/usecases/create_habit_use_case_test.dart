import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/habits/domain/usecases/create_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/delete_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/update_habit_use_case.dart';

class FakeHabitRepository implements HabitRepository {
  final List<Habit> _habits = [];

  @override
  Future<void> createHabit(Habit habit) async {
    _habits.add(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
  }

  @override
  Future<Habit?> getHabit(String id) async {
    final index = _habits.indexWhere((h) => h.id == id);
    return index != -1 ? _habits[index] : null;
  }

  @override
  Future<List<Habit>> getHabits() async {
    return List.unmodifiable(_habits);
  }

  @override
  Stream<List<Habit>> watchHabits() {
    return Stream.value(_habits);
  }
}

void main() {
  late FakeHabitRepository repository;
  late CreateHabitUseCase createHabitUseCase;
  late UpdateHabitUseCase updateHabitUseCase;
  late DeleteHabitUseCase deleteHabitUseCase;

  setUp(() {
    repository = FakeHabitRepository();
    createHabitUseCase = CreateHabitUseCase(repository);
    updateHabitUseCase = UpdateHabitUseCase(repository);
    deleteHabitUseCase = DeleteHabitUseCase(repository);
  });

  final now = DateTime.parse('2026-07-24T12:00:00.000Z');
  final testHabit = Habit(
    id: 'habit-101',
    title: 'Daily Meditation',
    description: '10 mins mindfulness',
    icon: 'meditation',
    color: HabitColor.teal,
    frequency: HabitFrequency.daily,
    habitType: HabitType.boolean,
    targetCount: 1,
    createdAt: now,
    updatedAt: now,
    isArchived: false,
  );

  group('Habit Use Cases Tests', () {
    test('CreateHabitUseCase saves habit to repository', () async {
      await createHabitUseCase.execute(testHabit);
      final habit = await repository.getHabit('habit-101');

      expect(habit, isNotNull);
      expect(habit?.title, equals('Daily Meditation'));
    });

    test('UpdateHabitUseCase modifies existing habit in repository', () async {
      await createHabitUseCase.execute(testHabit);
      final updated = testHabit.copyWith(title: '20 Mins Meditation');

      await updateHabitUseCase.execute(updated);
      final habit = await repository.getHabit('habit-101');

      expect(habit?.title, equals('20 Mins Meditation'));
    });

    test('DeleteHabitUseCase removes habit from repository', () async {
      await createHabitUseCase.execute(testHabit);
      await deleteHabitUseCase.execute('habit-101');
      final habit = await repository.getHabit('habit-101');

      expect(habit, isNull);
    });
  });
}
