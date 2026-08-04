import '../repositories/habit_repository.dart';

/// Use case for restoring an archived habit by its unique ID.
class RestoreHabitUseCase {
  final HabitRepository _repository;

  const RestoreHabitUseCase(this._repository);

  /// Restores the archived habit identified by [id].
  Future<void> execute(String id) {
    return _repository.restoreHabit(id);
  }
}
