import '../entities/daily_completion_stats.dart';
import '../entities/habit_log.dart';
import '../repositories/habit_repository.dart';

/// Use case for evaluating daily completion metrics across all habits for a target date.
class GetDailyCompletionUseCase {
  final HabitRepository _repository;

  const GetDailyCompletionUseCase(this._repository);

  /// Calculates overall habit completion stats for a specific [targetDate].
  Future<DailyCompletionStats> execute({DateTime? targetDate}) async {
    final date = targetDate ?? DateTime.now();
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final habits = await _repository.getHabits();
    final activeHabits = habits.where((h) => !h.isArchived).toList();

    if (activeHabits.isEmpty) {
      return DailyCompletionStats(
        date: normalizedDate,
        totalHabits: 0,
        completedHabits: 0,
        completionPercentage: 0.0,
        isFullyCompleted: false,
      );
    }

    final logs = await _repository.getLogsForDate(normalizedDate);
    final completedHabitIds = logs
        .where((log) => log.status == HabitLogStatus.completed)
        .map((log) => log.habitId)
        .toSet();

    int completedCount = 0;
    for (final habit in activeHabits) {
      if (completedHabitIds.contains(habit.id)) {
        completedCount++;
      }
    }

    final totalCount = activeHabits.length;
    final percentage = totalCount > 0 ? completedCount / totalCount : 0.0;
    final isFullyCompleted = totalCount > 0 && completedCount == totalCount;

    return DailyCompletionStats(
      date: normalizedDate,
      totalHabits: totalCount,
      completedHabits: completedCount,
      completionPercentage: percentage,
      isFullyCompleted: isFullyCompleted,
    );
  }
}
