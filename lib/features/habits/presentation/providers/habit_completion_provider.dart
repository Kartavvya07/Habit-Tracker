import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/daily_completion_stats.dart';
import '../../domain/entities/habit_log.dart';
import 'habit_providers.dart';
import 'use_case_providers.dart';

/// Stream provider exposing today's habit log entries.
final todayLogsStreamProvider = StreamProvider<List<HabitLog>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchTodayLogs(DateTime.now());
});

/// Reactive stream provider for aggregated daily habit completion statistics.
///
/// Automatically recomputes whenever the list of habits or today's log entries change.
final todayCompletionsProvider = StreamProvider<DailyCompletionStats>((ref) async* {
  ref.watch(habitsStreamProvider);
  ref.watch(todayLogsStreamProvider);
  final useCase = ref.watch(getDailyCompletionUseCaseProvider);
  yield await useCase.execute(targetDate: DateTime.now());
});
