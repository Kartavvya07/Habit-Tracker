import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/utils/duration_formatter.dart';

void main() {
  group('DurationFormatter Unit Tests', () {
    test('formatClock handles durations below 1 hour with MM:SS format', () {
      expect(DurationFormatter.formatClock(0), '00:00');
      expect(DurationFormatter.formatClock(45), '00:45');
      expect(DurationFormatter.formatClock(300), '05:00');
      expect(DurationFormatter.formatClock(1089), '18:09');
      expect(DurationFormatter.formatClock(3599), '59:59');
    });

    test('formatClock handles durations at or above 1 hour with HH:MM:SS format', () {
      expect(DurationFormatter.formatClock(3600), '01:00:00'); // 60 minutes
      expect(DurationFormatter.formatClock(3912), '01:05:12');
      expect(DurationFormatter.formatClock(4500), '01:15:00'); // 75 minutes
      expect(DurationFormatter.formatClock(7200), '02:00:00'); // 2 hours
      expect(DurationFormatter.formatClock(45340), '12:35:40');
      expect(DurationFormatter.formatClock(86400), '24:00:00'); // 24 hours
      expect(DurationFormatter.formatClock(172800), '48:00:00'); // 48 hours
      expect(DurationFormatter.formatClock(356400), '99:00:00'); // 99 hours
      expect(DurationFormatter.formatClock(359999), '99:59:59'); // 99 hours 59 min 59 sec
    });

    test('formatHuman returns adaptive human readable text accurately', () {
      expect(DurationFormatter.formatHuman(0), '0 sec');
      expect(DurationFormatter.formatHuman(45), '45 sec');
      expect(DurationFormatter.formatHuman(300), '5 min');
      expect(DurationFormatter.formatHuman(3540), '59 min');
      expect(DurationFormatter.formatHuman(3600), '1 hr');
      expect(DurationFormatter.formatHuman(4500), '1 hr 15 min');
      expect(DurationFormatter.formatHuman(7200), '2 hr');
      expect(DurationFormatter.formatHuman(86400), '24 hr');
      expect(DurationFormatter.formatHuman(172800), '48 hr');
      expect(DurationFormatter.formatHuman(356400), '99 hr');
    });
  });
}
