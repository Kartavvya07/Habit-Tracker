import '../repositories/habit_repository.dart';

/// Use case for permanently deleting a habit and its associated logs.
class DeleteHabitUseCase {
  final HabitRepository _repository;

  const DeleteHabitUseCase(this._repository);

  /// Deletes the habit identified by [id] from the repository.
  Future<void> execute(String id) {
    return _repository.deleteHabit(id);
  }
}
