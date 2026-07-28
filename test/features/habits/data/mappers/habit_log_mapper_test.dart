import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/features/habits/data/mappers/habit_log_mapper.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';

void main() {
  final testDate = DateTime.parse('2026-07-28T12:00:00.000Z');

  group('HabitLogMapper Tests', () {
    test('toEntity maps HabitLogTableData to HabitLog entity correctly', () {
      final tableData = HabitLogTableData(
        id: 'log-100',
        habitId: 'habit-200',
        targetDate: testDate,
        status: 'skipped',
        currentValue: 42,
        isFrozen: true,
      );

      final entity = HabitLogMapper.toEntity(tableData);

      expect(entity.id, equals('log-100'));
      expect(entity.habitId, equals('habit-200'));
      expect(entity.targetDate, equals(testDate));
      expect(entity.status, equals(HabitLogStatus.skipped));
      expect(entity.currentValue, equals(42));
      expect(entity.isFrozen, isTrue);
    });

    test('toEntity falls back to default status for unknown status string', () {
      final tableData = HabitLogTableData(
        id: 'log-101',
        habitId: 'habit-200',
        targetDate: testDate,
        status: 'invalid_status_value',
        currentValue: 0,
        isFrozen: false,
      );

      final entity = HabitLogMapper.toEntity(tableData);
      expect(entity.status, equals(HabitLogStatus.completed));
    });

    test('toCompanion maps HabitLog domain entity to HabitLogsCompanion correctly', () {
      final entity = HabitLog(
        id: 'log-102',
        habitId: 'habit-200',
        targetDate: testDate,
        status: HabitLogStatus.failed,
        currentValue: 10,
        isFrozen: false,
      );

      final companion = HabitLogMapper.toCompanion(entity);

      expect(companion.id.value, equals('log-102'));
      expect(companion.habitId.value, equals('habit-200'));
      expect(companion.targetDate.value, equals(testDate));
      expect(companion.status.value, equals('failed'));
      expect(companion.currentValue.value, equals(10));
      expect(companion.isFrozen.value, isFalse);
    });

    test('bidirectional mapping maintains data integrity', () {
      final originalEntity = HabitLog(
        id: 'log-103',
        habitId: 'habit-300',
        targetDate: testDate,
        status: HabitLogStatus.inProgress,
        currentValue: 75,
        isFrozen: true,
      );

      final companion = HabitLogMapper.toCompanion(originalEntity);
      final reconstructedData = HabitLogTableData(
        id: companion.id.value,
        habitId: companion.habitId.value,
        targetDate: companion.targetDate.value,
        status: companion.status.value,
        currentValue: companion.currentValue.value,
        isFrozen: companion.isFrozen.value,
      );

      final reconstructedEntity = HabitLogMapper.toEntity(reconstructedData);
      expect(reconstructedEntity, equals(originalEntity));
    });
  });
}
