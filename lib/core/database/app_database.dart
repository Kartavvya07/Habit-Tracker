import 'package:drift/drift.dart';
import 'tables/habits_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Habits])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

