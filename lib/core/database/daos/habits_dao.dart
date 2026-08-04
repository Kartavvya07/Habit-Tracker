import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habits_table.dart';

part 'habits_dao.g.dart';

@DriftAccessor(tables: [Habits])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  Future<void> insertHabit(HabitsCompanion habit) => into(habits).insert(habit);

  Future<bool> updateHabit(HabitsCompanion habit) => update(habits).replace(habit);

  Future<int> deleteHabit(String id) =>
      (delete(habits)..where((tbl) => tbl.id.equals(id))).go();

  Future<int> archiveHabit(String id, {DateTime? updatedAt}) =>
      (update(habits)..where((tbl) => tbl.id.equals(id))).write(
        HabitsCompanion(
          isArchived: const Value(true),
          updatedAt: Value(updatedAt ?? DateTime.now()),
        ),
      );

  Future<int> restoreHabit(String id, {DateTime? updatedAt}) =>
      (update(habits)..where((tbl) => tbl.id.equals(id))).write(
        HabitsCompanion(
          isArchived: const Value(false),
          updatedAt: Value(updatedAt ?? DateTime.now()),
        ),
      );

  Future<HabitTableData?> getHabitById(String id) =>
      (select(habits)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<List<HabitTableData>> getAllHabits() => (select(habits)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .get();

  Stream<List<HabitTableData>> watchAllHabits() => (select(habits)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .watch();

  Future<List<HabitTableData>> getActiveHabits() => (select(habits)
        ..where((tbl) => tbl.isArchived.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .get();

  Stream<List<HabitTableData>> watchActiveHabits() => (select(habits)
        ..where((tbl) => tbl.isArchived.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .watch();

  Future<List<HabitTableData>> getArchivedHabits() => (select(habits)
        ..where((tbl) => tbl.isArchived.equals(true))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .get();

  Stream<List<HabitTableData>> watchArchivedHabits() => (select(habits)
        ..where((tbl) => tbl.isArchived.equals(true))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
      .watch();
}
