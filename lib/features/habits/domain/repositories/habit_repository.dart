import '../entities/habit.dart';

abstract class HabitRepository {
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<Habit?> getHabit(String id);
  Stream<List<Habit>> watchHabits();
  Future<List<Habit>> getHabits();
}
