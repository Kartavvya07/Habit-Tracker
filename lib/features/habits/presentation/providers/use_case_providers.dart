import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/archive_habit_use_case.dart';
import '../../domain/usecases/calculate_streak_use_case.dart';
import '../../domain/usecases/create_habit_use_case.dart';
import '../../domain/usecases/delete_habit_use_case.dart';
import '../../domain/usecases/get_daily_completion_use_case.dart';
import '../../domain/usecases/log_habit_progress_use_case.dart';
import '../../domain/usecases/restore_habit_use_case.dart';
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

final archiveHabitUseCaseProvider = Provider<ArchiveHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return ArchiveHabitUseCase(repository);
});

final restoreHabitUseCaseProvider = Provider<RestoreHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return RestoreHabitUseCase(repository);
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return DeleteHabitUseCase(repository);
});

final logHabitProgressUseCaseProvider = Provider<LogHabitProgressUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return LogHabitProgressUseCase(repository);
});

final calculateStreakUseCaseProvider = Provider<CalculateStreakUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return CalculateStreakUseCase(repository);
});

final getDailyCompletionUseCaseProvider =
    Provider<GetDailyCompletionUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetDailyCompletionUseCase(repository);
});
