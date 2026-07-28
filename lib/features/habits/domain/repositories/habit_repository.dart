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
  Future<void> saveHabitLogs(List<HabitLog> logs);
  Future<void> logProgress(HabitLog log);
  Future<HabitLog?> getHabitLog(String id);
  Future<List<HabitLog>> getHabitLogs(String habitId);
  Future<List<HabitLog>> getLogsForHabit(String habitId);
  Stream<List<HabitLog>> watchHabitLogs(String habitId);
  Future<void> deleteHabitLog(String id);
  Future<void> deleteLog(String id);

  // Date & Feature Queries
  Stream<List<HabitLog>> watchTodayLogs(DateTime date);
  Future<List<HabitLog>> getLogsForDate(DateTime date);
  Future<List<HabitLog>> getLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  });
  Stream<List<HabitLog>> watchLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  });
  Future<List<HabitLog>> getLogsForHabits(List<String> habitIds);
  Future<List<HabitLog>> getLogsForHabitAndDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );
}

