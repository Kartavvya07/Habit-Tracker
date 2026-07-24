import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_habit_use_case.dart';
import '../../domain/usecases/delete_habit_use_case.dart';
import '../../domain/usecases/update_habit_use_case.dart';
import 'habit_providers.dart';

final createHabitUseCaseProvider = Provider<CreateHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return CreateHabitUseCase(repository);
});

final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return UpdateHabitUseCase(repository);
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return DeleteHabitUseCase(repository);
});
