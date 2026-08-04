import 'package:drift/drift.dart';
import 'daos/habit_logs_dao.dart';
import 'daos/habits_dao.dart';
import 'tables/habit_logs_table.dart';
import 'tables/habits_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Habits, HabitLogs], daos: [HabitLogsDao, HabitsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(habitLogs);
        }
      },
    );
  }
}
