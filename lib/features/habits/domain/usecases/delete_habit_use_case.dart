import '../repositories/habit_repository.dart';
import 'cancel_habit_reminders_use_case.dart';

/// Use case for permanently deleting a habit and its associated logs.
class DeleteHabitUseCase {
  final HabitRepository _repository;
  final CancelHabitRemindersUseCase? _cancelRemindersUseCase;

  const DeleteHabitUseCase(
    this._repository, [
    this._cancelRemindersUseCase,
  ]);

  /// Deletes the habit identified by [id] from the repository and cancels all reminders.
  Future<void> execute(String id) async {
    await _repository.deleteHabit(id);
    if (_cancelRemindersUseCase != null) {
      await _cancelRemindersUseCase.execute(id);
    }
  }
}
