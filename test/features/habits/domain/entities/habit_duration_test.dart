import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_duration.dart';

void main() {
  group('HabitDuration Tests', () {
    test('calculates hours, minutes, and seconds correctly', () {
      const duration = HabitDuration(9015); // 2 hr 30 min 15 sec
      expect(duration.hours, 2);
      expect(duration.minutes, 30);
      expect(duration.seconds, 15);
      expect(duration.toDuration(), const Duration(seconds: 9015));
    });

    test('creates from hours, minutes, and seconds factory', () {
      final duration = HabitDuration.fromHMSS(1, 15, 30);
      expect(duration.totalSeconds, 4530);
      expect(duration.hours, 1);
      expect(duration.minutes, 15);
      expect(duration.seconds, 30);
    });

    test('formats durations adaptively as specified', () {
      expect(const HabitDuration(45).formatted(), '45 sec');
      expect(const HabitDuration(90).formatted(), '1 min 30 sec');
      expect(const HabitDuration(900).formatted(), '15 min');
      expect(const HabitDuration(3600).formatted(), '1 hr');
      expect(const HabitDuration(4500).formatted(), '1 hr 15 min');
      expect(const HabitDuration(9000).formatted(), '2 hr 30 min');
      expect(const HabitDuration(9015).formatted(), '2 hr 30 min 15 sec');
      expect(const HabitDuration(0).formatted(), '0 sec');
    });

    test('formats digital clock string formattedClock correctly', () {
      expect(const HabitDuration(45).formattedClock(), '00:45');
      expect(const HabitDuration(300).formattedClock(), '05:00');
      expect(const HabitDuration(3540).formattedClock(), '59:00');
      expect(const HabitDuration(3600).formattedClock(), '01:00:00');
      expect(const HabitDuration(4500).formattedClock(), '01:15:00');
      expect(const HabitDuration(7200).formattedClock(), '02:00:00');
      expect(const HabitDuration(86400).formattedClock(), '24:00:00');
      expect(const HabitDuration(172800).formattedClock(), '48:00:00');
      expect(const HabitDuration(356400).formattedClock(), '99:00:00');
    });

    test('equality and hashCode match totalSeconds', () {
      const d1 = HabitDuration(300);
      const d2 = HabitDuration(300);
      const d3 = HabitDuration(400);

      expect(d1, equals(d2));
      expect(d1.hashCode, equals(d2.hashCode));
      expect(d1, isNot(equals(d3)));
    });
  });
}
