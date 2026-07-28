import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/vacation_mode_provider.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/streak_info.dart';
import 'habit_providers.dart';
import 'use_case_providers.dart';

/// Stream provider for logs belonging to a specific habit.
final habitLogsStreamProvider =
    StreamProvider.family<List<HabitLog>, String>((ref, habitId) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchHabitLogs(habitId);
});

/// Reactive stream provider calculating streak info for a habit.
///
/// Automatically recomputes whenever habit logs for [habitId] or [vacationModeProvider] change.
final streakProvider =
    StreamProvider.family<StreakInfo, String>((ref, habitId) async* {
  ref.watch(habitLogsStreamProvider(habitId));
  final isVacationModeActive = ref.watch(vacationModeProvider);
  final useCase = ref.watch(calculateStreakUseCaseProvider);
  yield await useCase.execute(
    habitId: habitId,
    isVacationModeActive: isVacationModeActive,
  );
});

