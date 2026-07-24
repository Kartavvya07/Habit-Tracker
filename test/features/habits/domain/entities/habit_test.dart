import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';

void main() {
  group('Habit Entity Test', () {
    final now = DateTime.parse('2026-07-24T12:00:00.000Z');
    final habit = Habit(
      id: 'habit-1',
      title: 'Morning Exercise',
      description: 'Do 30 mins workout',
      icon: 'fitness',
      color: HabitColor.green,
      frequency: HabitFrequency.daily,
      habitType: HabitType.boolean,
      targetCount: 1,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
    );

    test('supports value equality and immutability', () {
      final habit2 = Habit(
        id: 'habit-1',
        title: 'Morning Exercise',
        description: 'Do 30 mins workout',
        icon: 'fitness',
        color: HabitColor.green,
        frequency: HabitFrequency.daily,
        habitType: HabitType.boolean,
        targetCount: 1,
        createdAt: now,
        updatedAt: now,
        isArchived: false,
      );

      expect(habit, equals(habit2));
    });

    test('copyWith creates modified copy correctly', () {
      final updated = habit.copyWith(title: 'Evening Exercise', targetCount: 2);
      expect(updated.title, equals('Evening Exercise'));
      expect(updated.targetCount, equals(2));
      expect(updated.id, equals(habit.id));
    });

    test('serialization (toJson / fromJson) works correctly', () {
      final json = habit.toJson();
      expect(json['id'], equals('habit-1'));
      expect(json['title'], equals('Morning Exercise'));
      expect(json['color'], equals('green'));

      final deserialized = Habit.fromJson(json);
      expect(deserialized, equals(habit));
    });
  });
}
