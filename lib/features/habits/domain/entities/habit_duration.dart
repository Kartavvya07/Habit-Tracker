import 'package:flutter/foundation.dart';

/// Value object representing a habit duration with adaptive human-friendly formatting.
@immutable
class HabitDuration {
  final int totalSeconds;

  const HabitDuration(this.totalSeconds);

  factory HabitDuration.fromHMSS(int hours, int minutes, int seconds) {
    final total = (hours * 3600) + (minutes * 60) + seconds;
    return HabitDuration(total < 0 ? 0 : total);
  }

  int get hours => totalSeconds ~/ 3600;
  int get minutes => (totalSeconds % 3600) ~/ 60;
  int get seconds => totalSeconds % 60;

  Duration toDuration() => Duration(seconds: totalSeconds);

  /// Returns adaptive human-friendly formatted string.
  /// Examples:
  /// - 45 sec -> '45 sec'
  /// - 90 sec -> '1 min 30 sec'
  /// - 900 sec -> '15 min'
  /// - 3600 sec -> '1 hr'
  /// - 4500 sec -> '1 hr 15 min'
  /// - 9000 sec -> '2 hr 30 min'
  /// - 9015 sec -> '2 hr 30 min 15 sec'
  String formatted() {
    if (totalSeconds <= 0) return '0 sec';

    final hrs = hours;
    final mins = minutes;
    final secs = seconds;

    final parts = <String>[];
    if (hrs > 0) parts.add('$hrs hr');
    if (mins > 0) parts.add('$mins min');
    if (secs > 0) parts.add('$secs sec');

    return parts.isEmpty ? '0 sec' : parts.join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitDuration && totalSeconds == other.totalSeconds;

  @override
  int get hashCode => totalSeconds.hashCode;

  @override
  String toString() => formatted();
}
