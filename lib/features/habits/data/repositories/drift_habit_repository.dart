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

  DateTime _startOfDay(DateTime date) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, date.day)
        : DateTime(date.year, date.month, date.day);
  }

  DateTime _endOfDay(DateTime date) {
    return date.isUtc
        ? DateTime.utc(date.year, date.month, date.day, 23, 59, 59, 999, 999)
        : DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);
  }

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
  Future<void> saveHabitLogs(List<HabitLog> logs) async {
    if (logs.isEmpty) return;
    final companions = logs.map(HabitLogMapper.toCompanion).toList();
    await _db.habitLogsDao.upsertLogs(companions);
  }

  @override
  Future<void> logProgress(HabitLog log) async {
    await saveHabitLog(log);
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
  Future<List<HabitLog>> getLogsForHabit(String habitId) => getHabitLogs(habitId);

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

  @override
  Future<void> deleteLog(String id) => deleteHabitLog(id);

  // Date & Feature Queries
  @override
  Stream<List<HabitLog>> watchTodayLogs(DateTime date) {
    final start = _startOfDay(date);
    final end = _endOfDay(date);
    return _db.habitLogsDao.watchLogsForDate(start, end).map(
          (rows) => rows.map(HabitLogMapper.toEntity).toList(),
        );
  }

  @override
  Future<List<HabitLog>> getLogsForDate(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);
    final rows = await _db.habitLogsDao.getLogsForDate(start, end);
    return rows.map(HabitLogMapper.toEntity).toList();
  }

  @override
  Future<List<HabitLog>> getLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) async {
    final start = _startOfDay(startDate);
    final end = _endOfDay(endDate);
    final rows = await _db.habitLogsDao.getLogsForDateRange(
      start,
      end,
      habitIds: habitIds,
    );
    return rows.map(HabitLogMapper.toEntity).toList();
  }

  @override
  Stream<List<HabitLog>> watchLogsForDateRange(
    DateTime startDate,
    DateTime endDate, {
    List<String>? habitIds,
  }) {
    final start = _startOfDay(startDate);
    final end = _endOfDay(endDate);
    return _db.habitLogsDao
        .watchLogsForDateRange(
          start,
          end,
          habitIds: habitIds,
        )
        .map(
          (rows) => rows.map(HabitLogMapper.toEntity).toList(),
        );
  }

  @override
  Future<List<HabitLog>> getLogsForHabits(List<String> habitIds) async {
    if (habitIds.isEmpty) return [];
    final rows = await _db.habitLogsDao.getLogsForHabits(habitIds);
    return rows.map(HabitLogMapper.toEntity).toList();
  }

  @override
  Future<List<HabitLog>> getLogsForHabitAndDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = _startOfDay(startDate);
    final end = _endOfDay(endDate);
    final rows = await _db.habitLogsDao.getLogsForHabitAndDateRange(
      habitId,
      start,
      end,
    );
    return rows.map(HabitLogMapper.toEntity).toList();
  }
}

