import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/database/daos/habit_logs_dao.dart';

void main() {
  late AppDatabase db;
  late HabitLogsDao dao;

  final now = DateTime.parse('2026-07-28T12:00:00.000Z');

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dao = HabitLogsDao(db);

    // Create a parent habit entry to satisfy foreign key constraints
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            id: 'parent-habit-1',
            title: 'Daily Exercise',
            color: 'blue',
            frequency: 'daily',
            habitType: 'boolean',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('HabitLogsDao Tests', () {
    test('insertLog and getLogById insert and retrieve record', () async {
      final companion = HabitLogsCompanion.insert(
        id: 'log-1',
        habitId: 'parent-habit-1',
        targetDate: now,
        status: 'completed',
        currentValue: const Value(1),
        isFrozen: const Value(false),
      );

      await dao.insertLog(companion);
      final retrieved = await dao.getLogById('log-1');

      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals('log-1'));
      expect(retrieved?.habitId, equals('parent-habit-1'));
      expect(retrieved?.status, equals('completed'));
      expect(retrieved?.currentValue, equals(1));
    });

    test('upsertLog updates existing record on conflict', () async {
      final companion = HabitLogsCompanion.insert(
        id: 'log-1',
        habitId: 'parent-habit-1',
        targetDate: now,
        status: 'inProgress',
        currentValue: const Value(5),
      );
      await dao.insertLog(companion);

      final updatedCompanion = HabitLogsCompanion.insert(
        id: 'log-1',
        habitId: 'parent-habit-1',
        targetDate: now,
        status: 'completed',
        currentValue: const Value(10),
      );
      await dao.upsertLog(updatedCompanion);

      final retrieved = await dao.getLogById('log-1');
      expect(retrieved?.status, equals('completed'));
      expect(retrieved?.currentValue, equals(10));
    });

    test('getLogsForHabit filters logs by habitId', () async {
      // Add second parent habit
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              id: 'parent-habit-2',
              title: 'Read Books',
              color: 'green',
              frequency: 'daily',
              habitType: 'numeric',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await dao.insertLog(
        HabitLogsCompanion.insert(
          id: 'log-1',
          habitId: 'parent-habit-1',
          targetDate: now,
          status: 'completed',
        ),
      );
      await dao.insertLog(
        HabitLogsCompanion.insert(
          id: 'log-2',
          habitId: 'parent-habit-2',
          targetDate: now,
          status: 'skipped',
        ),
      );

      final habit1Logs = await dao.getLogsForHabit('parent-habit-1');
      final habit2Logs = await dao.getLogsForHabit('parent-habit-2');

      expect(habit1Logs.length, equals(1));
      expect(habit1Logs.single.id, equals('log-1'));

      expect(habit2Logs.length, equals(1));
      expect(habit2Logs.single.id, equals('log-2'));
    });

    test('watchLogsForHabit emits updates when new log inserted', () async {
      final emissions = <List<HabitLogTableData>>[];
      final subscription = dao.watchLogsForHabit('parent-habit-1').listen(emissions.add);

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, isEmpty);

      await dao.insertLog(
        HabitLogsCompanion.insert(
          id: 'log-1',
          habitId: 'parent-habit-1',
          targetDate: now,
          status: 'completed',
        ),
      );

      await Future<void>.delayed(Duration.zero);
      expect(emissions.last.length, equals(1));
      expect(emissions.last.single.id, equals('log-1'));

      await subscription.cancel();
    });

    test('deleteLog removes log from database', () async {
      await dao.insertLog(
        HabitLogsCompanion.insert(
          id: 'log-1',
          habitId: 'parent-habit-1',
          targetDate: now,
          status: 'completed',
        ),
      );

      final deletedRows = await dao.deleteLog('log-1');
      expect(deletedRows, equals(1));

      final retrieved = await dao.getLogById('log-1');
      expect(retrieved, isNull);
    });
  });
}
