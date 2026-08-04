import '../repositories/habit_repository.dart';

/// Use case for archiving an existing habit by its unique ID.
class ArchiveHabitUseCase {
  final HabitRepository _repository;

  const ArchiveHabitUseCase(this._repository);

  /// Archives the habit identified by [id].
  Future<void> execute(String id) {
    return _repository.archiveHabit(id);
  }
}
