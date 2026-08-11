import '../repositories/habit_repository.dart';
import 'cancel_habit_reminders_use_case.dart';

/// Use case for archiving an existing habit by its unique ID.
class ArchiveHabitUseCase {
  final HabitRepository _repository;
  final CancelHabitRemindersUseCase? _cancelRemindersUseCase;

  const ArchiveHabitUseCase(
    this._repository, [
    this._cancelRemindersUseCase,
  ]);

  /// Archives the habit identified by [id] and cancels its reminders.
  Future<void> execute(String id) async {
    await _repository.archiveHabit(id);
    if (_cancelRemindersUseCase != null) {
      await _cancelRemindersUseCase.execute(id);
    }
  }
}
