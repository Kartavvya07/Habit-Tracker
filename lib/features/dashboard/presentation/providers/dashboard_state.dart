import 'package:equatable/equatable.dart';
import '../../../habits/domain/entities/habit.dart';

/// Represents the presentation states for the Dashboard.
sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before the habit stream emits its first value.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// State when no habits exist in the database.
final class DashboardEmpty extends DashboardState {
  const DashboardEmpty();
}

/// State when habits exist.
/// Contains [habits] ordered by the repository (createdAt DESC).
final class DashboardLoaded extends DashboardState {
  final List<Habit> habits;

  const DashboardLoaded(this.habits);

  @override
  List<Object?> get props => [habits];
}

/// State when repository stream fails or throws an exception.
final class DashboardError extends DashboardState {
  final String message;
  final Object? error;

  const DashboardError(this.message, [this.error]);

  @override
  List<Object?> get props => [message, error];
}
