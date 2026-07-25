import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import 'dashboard_state.dart';

/// Provider for the [DashboardState].
///
/// Consumes [habitsStreamProvider] which watches [HabitRepository.watchHabits()].
/// Transforms raw habit list emissions into presentation-ready dashboard states:
/// - [DashboardLoading] on initial load
/// - [DashboardEmpty] when no habits exist
/// - [DashboardLoaded] containing habits in repository order
/// - [DashboardError] when stream emits an error
final dashboardProvider = Provider<DashboardState>((ref) {
  final asyncHabits = ref.watch(habitsStreamProvider);
  return asyncHabits.when(
    data: (habits) =>
        habits.isEmpty ? const DashboardEmpty() : DashboardLoaded(habits),
    loading: () => const DashboardLoading(),
    error: (error, stackTrace) => DashboardError(
      error.toString(),
      error,
    ),
  );
});
