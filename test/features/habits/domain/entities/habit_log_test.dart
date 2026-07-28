import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_log.dart';

void main() {
  final testDate = DateTime.parse('2026-07-28T10:00:00.000Z');

  group('HabitLog Entity Tests', () {
    test('instantiates with default values', () {
      final log = HabitLog(
        id: 'log-1',
        habitId: 'habit-1',
        targetDate: testDate,
      );

      expect(log.id, equals('log-1'));
      expect(log.habitId, equals('habit-1'));
      expect(log.targetDate, equals(testDate));
      expect(log.status, equals(HabitLogStatus.completed));
      expect(log.currentValue, equals(0));
      expect(log.isFrozen, isFalse);
    });

    test('supports copyWith modification', () {
      final log = HabitLog(
        id: 'log-1',
        habitId: 'habit-1',
        targetDate: testDate,
      );

      final updated = log.copyWith(
        status: HabitLogStatus.inProgress,
        currentValue: 15,
        isFrozen: true,
      );

      expect(updated.id, equals('log-1'));
      expect(updated.status, equals(HabitLogStatus.inProgress));
      expect(updated.currentValue, equals(15));
      expect(updated.isFrozen, isTrue);
    });

    test('serializes to and from JSON accurately', () {
      final log = HabitLog(
        id: 'log-1',
        habitId: 'habit-1',
        targetDate: testDate,
        status: HabitLogStatus.skipped,
        currentValue: 5,
        isFrozen: true,
      );

      final json = log.toJson();
      final fromJson = HabitLog.fromJson(json);

      expect(fromJson, equals(log));
      expect(json['id'], equals('log-1'));
      expect(json['status'], equals('skipped'));
      expect(json['currentValue'], equals(5));
      expect(json['isFrozen'], isTrue);
    });
  });
}
