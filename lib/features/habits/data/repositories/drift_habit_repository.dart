import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';
import '../mappers/habit_log_mapper.dart';
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
    final query = _db.select(_db.habits)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    return query.watch().map(
          (rows) => rows.map(HabitMapper.toEntity).toList(),
        );
  }

  @override
  Future<List<Habit>> getHabits() async {
    final query = _db.select(_db.habits)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    final rows = await query.get();
    return rows.map(HabitMapper.toEntity).toList();
  }

  // Habit Log Persistence Methods
  @override
  Future<void> saveHabitLog(HabitLog log) async {
    await _db.habitLogsDao.upsertLog(HabitLogMapper.toCompanion(log));
  }

  @override
  Future<HabitLog?> getHabitLog(String id) async {
    final result = await _db.habitLogsDao.getLogById(id);
    return result != null ? HabitLogMapper.toEntity(result) : null;
  }

  @override
  Future<List<HabitLog>> getHabitLogs(String habitId) async {
    final rows = await _db.habitLogsDao.getLogsForHabit(habitId);
    return rows.map(HabitLogMapper.toEntity).toList();
  }

  @override
  Stream<List<HabitLog>> watchHabitLogs(String habitId) {
    return _db.habitLogsDao.watchLogsForHabit(habitId).map(
          (rows) => rows.map(HabitLogMapper.toEntity).toList(),
        );
  }

  @override
  Future<void> deleteHabitLog(String id) async {
    await _db.habitLogsDao.deleteLog(id);
  }
}
