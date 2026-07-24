import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabitUseCase {
  final HabitRepository _repository;

  const UpdateHabitUseCase(this._repository);

  Future<void> execute(Habit habit) {
    return _repository.updateHabit(habit);
  }
}
