import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for updating an existing habit entity's properties.
class UpdateHabitUseCase {
  final HabitRepository _repository;

  const UpdateHabitUseCase(this._repository);

  /// Updates the specified [habit] details in the repository.
  Future<void> execute(Habit habit) {
    return _repository.updateHabit(habit);
  }
}
