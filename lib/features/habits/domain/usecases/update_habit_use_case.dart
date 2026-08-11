import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import 'cancel_habit_reminders_use_case.dart';
import 'schedule_habit_reminders_use_case.dart';

/// Use case for updating an existing habit entity's properties.
class UpdateHabitUseCase {
  final HabitRepository _repository;
  final ScheduleHabitRemindersUseCase? _scheduleRemindersUseCase;
  final CancelHabitRemindersUseCase? _cancelRemindersUseCase;

  const UpdateHabitUseCase(
    this._repository, [
    this._scheduleRemindersUseCase,
    this._cancelRemindersUseCase,
  ]);

  /// Updates the specified [habit] details in the repository.
  Future<void> execute(Habit habit) async {
    await _repository.updateHabit(habit);
    if (_cancelRemindersUseCase != null) {
      await _cancelRemindersUseCase.execute(habit.id);
    }
    if (_scheduleRemindersUseCase != null && habit.isReminderEnabled) {
      await _scheduleRemindersUseCase.execute(habit);
    }
  }
}
