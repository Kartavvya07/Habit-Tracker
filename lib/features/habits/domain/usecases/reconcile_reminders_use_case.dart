import '../repositories/habit_repository.dart';
import 'schedule_habit_reminders_use_case.dart';

/// Use case invoked at app startup / device reboot to reconcile and reschedule
/// all active habit reminders.
class ReconcileRemindersUseCase {
  final HabitRepository _repository;
  final ScheduleHabitRemindersUseCase _scheduleRemindersUseCase;

  const ReconcileRemindersUseCase(
    this._repository,
    this._scheduleRemindersUseCase,
  );

  /// Reschedules all enabled reminders for active habits.
  Future<void> execute() async {
    final activeHabits = await _repository.getActiveHabits();
    for (final habit in activeHabits) {
      if (habit.isReminderEnabled && habit.reminderTime != null) {
        await _scheduleRemindersUseCase.execute(habit);
      }
    }
  }
}
