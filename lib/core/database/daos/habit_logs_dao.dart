import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habit_logs_table.dart';

part 'habit_logs_dao.g.dart';

@DriftAccessor(tables: [HabitLogs])
class HabitLogsDao extends DatabaseAccessor<AppDatabase> with _$HabitLogsDaoMixin {
  HabitLogsDao(super.db);

  Future<void> insertLog(HabitLogsCompanion log) => into(habitLogs).insert(log);

  Future<void> upsertLog(HabitLogsCompanion log) => into(habitLogs).insertOnConflictUpdate(log);

  Future<void> upsertLogs(List<HabitLogsCompanion> logs) => batch((b) {
        b.insertAllOnConflictUpdate(habitLogs, logs);
      });

  Future<HabitLogTableData?> getLogById(String id) =>
      (select(habitLogs)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<HabitLogTableData>> getLogsForHabit(String habitId) =>
      (select(habitLogs)..where((tbl) => tbl.habitId.equals(habitId))).get();

  Stream<List<HabitLogTableData>> watchLogsForHabit(String habitId) =>
      (select(habitLogs)..where((tbl) => tbl.habitId.equals(habitId))).watch();

  Future<List<HabitLogTableData>> getLogsForDate(DateTime startOfDay, DateTime endOfDay) =>
      (select(habitLogs)
        ..where((tbl) => tbl.targetDate.isBetweenValues(startOfDay, endOfDay)))
      .get();

  Stream<List<HabitLogTableData>> watchLogsForDate(DateTime startOfDay, DateTime endOfDay) =>
      (select(habitLogs)
        ..where((tbl) => tbl.targetDate.isBetweenValues(startOfDay, endOfDay)))
      .watch();

  Future<List<HabitLogTableData>> getLogsForDateRange(
    DateTime startOfRange,
    DateTime endOfRange, {
    List<String>? habitIds,
  }) {
    final query = select(habitLogs)
      ..where((tbl) => tbl.targetDate.isBetweenValues(startOfRange, endOfRange));
    if (habitIds != null && habitIds.isNotEmpty) {
      query.where((tbl) => tbl.habitId.isIn(habitIds));
    }
    return query.get();
  }

  Stream<List<HabitLogTableData>> watchLogsForDateRange(
    DateTime startOfRange,
    DateTime endOfRange, {
    List<String>? habitIds,
  }) {
    final query = select(habitLogs)
      ..where((tbl) => tbl.targetDate.isBetweenValues(startOfRange, endOfRange));
    if (habitIds != null && habitIds.isNotEmpty) {
      query.where((tbl) => tbl.habitId.isIn(habitIds));
    }
    return query.watch();
  }

  Future<List<HabitLogTableData>> getLogsForHabits(List<String> habitIds) {
    if (habitIds.isEmpty) return Future.value([]);
    return (select(habitLogs)..where((tbl) => tbl.habitId.isIn(habitIds))).get();
  }

  Future<List<HabitLogTableData>> getLogsForHabitAndDateRange(
    String habitId,
    DateTime startOfRange,
    DateTime endOfRange,
  ) =>
      (select(habitLogs)
        ..where(
          (tbl) =>
              tbl.habitId.equals(habitId) &
              tbl.targetDate.isBetweenValues(startOfRange, endOfRange),
        ))
      .get();

  Stream<List<HabitLogTableData>> watchLogsForHabitAndDateRange(
    String habitId,
    DateTime startOfRange,
    DateTime endOfRange,
  ) =>
      (select(habitLogs)
        ..where(
          (tbl) =>
              tbl.habitId.equals(habitId) &
              tbl.targetDate.isBetweenValues(startOfRange, endOfRange),
        ))
      .watch();

  Future<int> deleteLog(String id) =>
      (delete(habitLogs)..where((tbl) => tbl.id.equals(id))).go();
}

