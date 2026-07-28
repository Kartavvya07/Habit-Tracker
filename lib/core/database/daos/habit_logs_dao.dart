import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habit_logs_table.dart';

part 'habit_logs_dao.g.dart';

@DriftAccessor(tables: [HabitLogs])
class HabitLogsDao extends DatabaseAccessor<AppDatabase> with _$HabitLogsDaoMixin {
  HabitLogsDao(super.db);

  Future<void> insertLog(HabitLogsCompanion log) => into(habitLogs).insert(log);

  Future<void> upsertLog(HabitLogsCompanion log) => into(habitLogs).insertOnConflictUpdate(log);

  Future<HabitLogTableData?> getLogById(String id) =>
      (select(habitLogs)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<HabitLogTableData>> getLogsForHabit(String habitId) =>
      (select(habitLogs)..where((tbl) => tbl.habitId.equals(habitId))).get();

  Stream<List<HabitLogTableData>> watchLogsForHabit(String habitId) =>
      (select(habitLogs)..where((tbl) => tbl.habitId.equals(habitId))).watch();

  Future<int> deleteLog(String id) =>
      (delete(habitLogs)..where((tbl) => tbl.id.equals(id))).go();
}
