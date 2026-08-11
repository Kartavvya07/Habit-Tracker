import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';

void main() {
  group('Database Schema & Migration Tests', () {
    test('schema version is 3', () {
      final db = AppDatabase(NativeDatabase.memory());
      expect(db.schemaVersion, equals(3));
      db.close();
    });

    test('Migration to schema version 3 creates habit_logs table and reminder columns', () async {
      // Step 1: Initialize database schema
      final executor = NativeDatabase.memory();
      final rawDb = AppDatabase(executor);

      // Verify opening db runs migration and creates tables
      await rawDb.customStatement('SELECT 1;');

      // Query sqlite_master to verify tables exist
      final tables = await rawDb.customSelect(
        "SELECT name FROM sqlite_master WHERE type='table';",
      ).get();

      final tableNames = tables.map((row) => row.read<String>('name')).toList();

      expect(tableNames, contains('habits'));
      expect(tableNames, contains('habit_logs'));

      // Verify reminder columns exist in habits table
      final pragmaColumns = await rawDb.customSelect(
        "PRAGMA table_info('habits');",
      ).get();

      final columnNames =
          pragmaColumns.map((row) => row.read<String>('name')).toList();

      expect(columnNames, contains('reminder_time'));
      expect(columnNames, contains('is_reminder_enabled'));

      await rawDb.close();
    });

    test('Foreign key constraint enforces CASCADE deletion of habit_logs when habit is deleted', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.parse('2026-07-28T12:00:00.000Z');

      // Insert habit into habits table
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              id: 'habit-cascade-1',
              title: 'Cascade Test Habit',
              color: 'blue',
              frequency: 'daily',
              habitType: 'boolean',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Insert habit log into habit_logs table
      await db.habitLogsDao.insertLog(
        HabitLogsCompanion.insert(
          id: 'log-cascade-1',
          habitId: 'habit-cascade-1',
          targetDate: now,
          status: 'completed',
        ),
      );

      // Verify habit log exists
      final logBeforeDelete = await db.habitLogsDao.getLogById('log-cascade-1');
      expect(logBeforeDelete, isNotNull);

      // Delete parent habit from habits table
      await (db.delete(db.habits)..where((tbl) => tbl.id.equals('habit-cascade-1'))).go();

      // Verify habit log is automatically deleted via foreign key CASCADE
      final logAfterDelete = await db.habitLogsDao.getLogById('log-cascade-1');
      expect(logAfterDelete, isNull);

      await db.close();
    });

    test('Composite index idx_habit_logs_habit_target_date exists in SQLite master', () async {
      final db = AppDatabase(NativeDatabase.memory());

      // Trigger database opening and migration
      await db.customStatement('SELECT 1;');

      final indices = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index';",
      ).get();

      final indexNames = indices.map((row) => row.read<String>('name')).toList();

      expect(indexNames, contains('idx_habit_logs_habit_target_date'));

      await db.close();
    });
  });
}
