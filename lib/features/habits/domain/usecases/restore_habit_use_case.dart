import '../repositories/habit_repository.dart';
import 'schedule_habit_reminders_use_case.dart';

/// Use case for restoring an archived habit by its unique ID.
class RestoreHabitUseCase {
  final HabitRepository _repository;
  final ScheduleHabitRemindersUseCase? _scheduleRemindersUseCase;

  const RestoreHabitUseCase(
    this._repository, [
    this._scheduleRemindersUseCase,
  ]);

  /// Restores the archived habit identified by [id] and reschedules reminders.
  Future<void> execute(String id) async {
    await _repository.restoreHabit(id);
    if (_scheduleRemindersUseCase != null) {
      final habit = await _repository.getHabit(id);
      if (habit != null && habit.isReminderEnabled) {
        await _scheduleRemindersUseCase.execute(habit);
      }
    }
  }
}
