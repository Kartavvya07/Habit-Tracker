import 'dart:math';

import '../entities/habit.dart';
import '../entities/habit_frequency.dart';
import '../entities/habit_log.dart';
import '../entities/streak_info.dart';
import '../repositories/habit_repository.dart';

/// Calculates streak metrics (current streak, best streak, completion rate) for a habit.
class CalculateStreakUseCase {
  final HabitRepository _repository;

  const CalculateStreakUseCase(this._repository);

  /// Executes calculation by fetching habit and logs from [HabitRepository].
  Future<StreakInfo> execute({
    required String habitId,
    DateTime? referenceDate,
    bool isVacationModeActive = false,
  }) async {
    final habit = await _repository.getHabit(habitId);
    if (habit == null) {
      return const StreakInfo();
    }

    final logs = await _repository.getLogsForHabit(habitId);
    return calculate(
      habit,
      logs,
      referenceDate: referenceDate,
      isVacationModeActive: isVacationModeActive,
    );
  }

  /// Pure calculation algorithm for streak metrics.
  StreakInfo calculate(
    Habit habit,
    List<HabitLog> logs, {
    DateTime? referenceDate,
    bool isVacationModeActive = false,
  }) {
    if (logs.isEmpty) {
      return const StreakInfo(
        currentStreak: 0,
        bestStreak: 0,
        completionRate: 0.0,
        totalCompleted: 0,
        totalScheduled: 0,
      );
    }

    final refDate = referenceDate ?? DateTime.now();
    final normalizedRefDate =
        DateTime(refDate.year, refDate.month, refDate.day);

    // Map logs by date (start of day)
    final Map<DateTime, HabitLog> logMap = {};
    for (final log in logs) {
      final date = DateTime(
        log.targetDate.year,
        log.targetDate.month,
        log.targetDate.day,
      );
      if (!logMap.containsKey(date) ||
          log.status == HabitLogStatus.completed) {
        logMap[date] = log;
      }
    }

    // Earliest date to start evaluation (habit.createdAt or earliest log)
    final createdAtDate = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    DateTime earliestLogDate = normalizedRefDate;
    for (final date in logMap.keys) {
      if (date.isBefore(earliestLogDate)) {
        earliestLogDate = date;
      }
    }
    final startDate = createdAtDate.isBefore(earliestLogDate)
        ? createdAtDate
        : earliestLogDate;

    if (startDate.isAfter(normalizedRefDate)) {
      return const StreakInfo();
    }

    // Determine current streak
    int currentStreak = 0;
    DateTime checkDate = normalizedRefDate;

    // Check if today has log
    final todayLog = logMap[normalizedRefDate];
    final isTodayCompleted = todayLog?.status == HabitLogStatus.completed;
    final isTodayProtected = todayLog?.isFrozen == true ||
        todayLog?.status == HabitLogStatus.skipped ||
        isVacationModeActive;

    if (!isTodayCompleted && !isTodayProtected) {
      // Today is not completed yet, start streak check from yesterday
      checkDate = normalizedRefDate.subtract(const Duration(days: 1));
    }

    while (!checkDate.isBefore(startDate)) {
      final isScheduled = _isScheduledDay(habit, checkDate);
      if (isScheduled) {
        final log = logMap[checkDate];
        if (log?.status == HabitLogStatus.completed) {
          currentStreak++;
        } else if (log?.isFrozen == true ||
            log?.status == HabitLogStatus.skipped ||
            isVacationModeActive) {
          // Streak protection preserves streak count without breaking
        } else {
          // Missed/failed on a scheduled day breaks the streak
          break;
        }
      }
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Calculate best streak and completion stats chronologically
    int bestStreak = 0;
    int tempStreak = 0;
    int totalCompleted = 0;
    int totalScheduled = 0;

    DateTime curr = startDate;
    while (!curr.isAfter(normalizedRefDate)) {
      final isScheduled = _isScheduledDay(habit, curr);
      if (isScheduled) {
        totalScheduled++;
        final log = logMap[curr];
        if (log?.status == HabitLogStatus.completed) {
          totalCompleted++;
          tempStreak++;
          bestStreak = max(bestStreak, tempStreak);
        } else if (log?.isFrozen == true ||
            log?.status == HabitLogStatus.skipped ||
            isVacationModeActive) {
          // Protected day: streak preserved
        } else {
          // Missed day: reset current chain
          tempStreak = 0;
        }
      }
      curr = curr.add(const Duration(days: 1));
    }

    bestStreak = max(bestStreak, currentStreak);

    final completionRate =
        totalScheduled > 0 ? (totalCompleted / totalScheduled) : 0.0;

    return StreakInfo(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      completionRate: completionRate > 1.0 ? 1.0 : completionRate,
      totalCompleted: totalCompleted,
      totalScheduled: totalScheduled,
    );
  }


  bool _isScheduledDay(Habit habit, DateTime date) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return true;
      case HabitFrequency.monthly:
        return true;
    }
  }
}
