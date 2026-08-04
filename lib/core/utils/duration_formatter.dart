import 'package:flutter/foundation.dart';

/// Central utility for consistent duration string formatting across the app.
@immutable
abstract class DurationFormatter {
  /// Formats total seconds into a digital clock string.
  ///
  /// Rules:
  /// - If duration < 1 hour (< 3600 seconds): `MM:SS` (e.g. `05:32`, `18:09`, `59:59`, `00:45`, `00:00`)
  /// - If duration >= 1 hour (>= 3600 seconds): `HH:MM:SS` (e.g. `01:05:12`, `02:00:00`, `24:00:00`, `48:00:00`, `99:59:59`)
  static String formatClock(int totalSeconds) {
    final seconds = totalSeconds < 0 ? 0 : totalSeconds;
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final minsStr = mins.toString().padLeft(2, '0');
    final secsStr = secs.toString().padLeft(2, '0');

    if (hrs > 0) {
      final hrsStr = hrs.toString().padLeft(2, '0');
      return '$hrsStr:$minsStr:$secsStr';
    }

    return '$minsStr:$secsStr';
  }

  /// Formats total seconds into an adaptive human-friendly string.
  /// Examples:
  /// - 45 sec -> '45 sec'
  /// - 300 sec -> '5 min'
  /// - 3600 sec -> '1 hr'
  /// - 4500 sec -> '1 hr 15 min'
  /// - 9000 sec -> '2 hr 30 min'
  /// - 9015 sec -> '2 hr 30 min 15 sec'
  static String formatHuman(int totalSeconds) {
    if (totalSeconds <= 0) return '0 sec';

    final hrs = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;

    final parts = <String>[];
    if (hrs > 0) parts.add('$hrs hr');
    if (mins > 0) parts.add('$mins min');
    if (secs > 0) parts.add('$secs sec');

    return parts.isEmpty ? '0 sec' : parts.join(' ');
  }
}
