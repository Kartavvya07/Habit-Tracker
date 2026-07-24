import 'package:drift/drift.dart';
import 'connection/open_connection.dart';

part 'app_database.g.dart';

/// Central Drift SQLite database class for the application infrastructure.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbName) : super(openConnection(dbName));

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;
}
