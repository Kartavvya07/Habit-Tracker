import '../entities/habit_log.dart';
import '../entities/habit_type.dart';
import '../repositories/habit_repository.dart';

/// Use case for logging progress on a habit for a given date.
///
/// Handles boolean, numeric counter, and timer habit types.
/// Evaluates status (`completed`, `inProgress`, `failed`, `skipped`) based on target values.
/// Validates progress inputs (e.g. preventing negative values).
class LogHabitProgressUseCase {
  final HabitRepository _repository;

  const LogHabitProgressUseCase(this._repository);

  /// Executes progress logging for [habitId] on [targetDate].
  ///
  /// Either [value], [valueDelta], or an explicit [status] can be passed.
  /// Throws [ArgumentError] if the habit is not found or if the resulting value is negative.
  Future<HabitLog> execute({
    required String habitId,
    DateTime? targetDate,
    int? value,
    int? valueDelta,
    HabitLogStatus? status,
    bool? isFrozen,
    String? logId,
  }) async {
    final habit = await _repository.getHabit(habitId);
    if (habit == null) {
      throw ArgumentError('Habit with id "$habitId" not found');
    }

    final date = targetDate ?? DateTime.now();
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Fetch existing logs for this date
    final existingLogs = await _repository.getLogsForHabitAndDateRange(
      habitId,
      normalizedDate,
      normalizedDate,
    );
    final existingLog = existingLogs.isNotEmpty ? existingLogs.first : null;

    int newCurrentValue;
    if (value != null) {
      if (value < 0) {
        throw ArgumentError('Progress value cannot be negative');
      }
      newCurrentValue = value;
    } else if (valueDelta != null) {
      final current = existingLog?.currentValue ?? 0;
      newCurrentValue = current + valueDelta;
      if (newCurrentValue < 0) {
        throw ArgumentError('Progress value cannot be negative');
      }
    } else if (status == HabitLogStatus.completed &&
        habit.habitType == HabitType.boolean) {
      newCurrentValue = habit.targetCount;
    } else {
      newCurrentValue = existingLog?.currentValue ?? 0;
    }

    HabitLogStatus evaluatedStatus;
    if (status != null) {
      evaluatedStatus = status;
    } else {
      if (newCurrentValue >= habit.targetCount) {
        evaluatedStatus = HabitLogStatus.completed;
      } else if (newCurrentValue > 0) {
        evaluatedStatus = HabitLogStatus.inProgress;
      } else {
        evaluatedStatus = HabitLogStatus.failed;
      }
    }

    final logToSave = HabitLog(
      id: logId ??
          existingLog?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      habitId: habitId,
      targetDate: normalizedDate,
      status: evaluatedStatus,
      currentValue: newCurrentValue,
      isFrozen: isFrozen ?? existingLog?.isFrozen ?? false,
    );

    await _repository.saveHabitLog(logToSave);
    return logToSave;
  }
}
