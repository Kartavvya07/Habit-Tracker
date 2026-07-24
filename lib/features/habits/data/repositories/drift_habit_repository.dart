import '../../../../core/database/app_database.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../models/habit_mapper.dart';


class DriftHabitRepository implements HabitRepository {
  final AppDatabase _db;

  DriftHabitRepository(this._db);

  @override
  Future<void> createHabit(Habit habit) async {
    await _db.into(_db.habits).insert(HabitMapper.toCompanion(habit));
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    await (_db.update(_db.habits)..where((tbl) => tbl.id.equals(habit.id)))
        .write(HabitMapper.toCompanion(habit));
  }

  @override
  Future<void> deleteHabit(String id) async {
    await (_db.delete(_db.habits)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<Habit?> getHabit(String id) async {
    final query = _db.select(_db.habits)..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? HabitMapper.toEntity(result) : null;
  }

  @override
  Stream<List<Habit>> watchHabits() {
    return _db.select(_db.habits).watch().map(
          (rows) => rows.map(HabitMapper.toEntity).toList(),
        );
  }

  @override
  Future<List<Habit>> getHabits() async {
    final rows = await _db.select(_db.habits).get();
    return rows.map(HabitMapper.toEntity).toList();
  }
}
