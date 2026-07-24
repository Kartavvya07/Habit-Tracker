import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  final HabitRepository _repository;

  const DeleteHabitUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteHabit(id);
  }
}
