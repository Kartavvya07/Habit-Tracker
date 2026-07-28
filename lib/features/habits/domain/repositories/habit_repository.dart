import '../entities/habit.dart';
import '../entities/habit_log.dart';

abstract class HabitRepository {
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<Habit?> getHabit(String id);
  Stream<List<Habit>> watchHabits();
  Future<List<Habit>> getHabits();

  // Habit Log Persistence Methods
  Future<void> saveHabitLog(HabitLog log);
  Future<HabitLog?> getHabitLog(String id);
  Future<List<HabitLog>> getHabitLogs(String habitId);
  Stream<List<HabitLog>> watchHabitLogs(String habitId);
  Future<void> deleteHabitLog(String id);
}
