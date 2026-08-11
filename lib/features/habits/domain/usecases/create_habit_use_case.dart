import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import 'schedule_habit_reminders_use_case.dart';

class CreateHabitUseCase {
  final HabitRepository _repository;
  final ScheduleHabitRemindersUseCase? _scheduleRemindersUseCase;

  const CreateHabitUseCase(
    this._repository, [
    this._scheduleRemindersUseCase,
  ]);

  Future<void> execute(Habit habit) async {
    await _repository.createHabit(habit);
    if (_scheduleRemindersUseCase != null && habit.isReminderEnabled) {
      await _scheduleRemindersUseCase.execute(habit);
    }
  }
}
