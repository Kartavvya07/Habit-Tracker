import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  final HabitRepository _repository;

  const CreateHabitUseCase(this._repository);

  Future<void> execute(Habit habit) {
    return _repository.createHabit(habit);
  }
}
