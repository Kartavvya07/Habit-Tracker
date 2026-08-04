import 'package:flutter/foundation.dart';
import '../../../../core/utils/duration_formatter.dart';

/// Value object representing a habit duration with adaptive human-friendly and digital clock formatting.
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

  /// Returns adaptive human-friendly formatted string (e.g. '1 hr 15 min').
  String formatted() => DurationFormatter.formatHuman(totalSeconds);

  /// Returns digital clock formatted string ('MM:SS' if < 1h, 'HH:MM:SS' if >= 1h).
  String formattedClock() => DurationFormatter.formatClock(totalSeconds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitDuration && totalSeconds == other.totalSeconds;

  @override
  int get hashCode => totalSeconds.hashCode;

  @override
  String toString() => formatted();
}
