import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/repositories/drift_habit_repository.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftHabitRepository(db);
});

final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchHabits();
});

