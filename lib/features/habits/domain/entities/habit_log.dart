import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_log.freezed.dart';
part 'habit_log.g.dart';

enum HabitLogStatus {
  completed,
  skipped,
  failed,
  inProgress,
}

@freezed
class HabitLog with _$HabitLog {
  const factory HabitLog({
    required String id,
    required String habitId,
    required DateTime targetDate,
    @Default(HabitLogStatus.completed) HabitLogStatus status,
    @Default(0) int currentValue,
    @Default(false) bool isFrozen,
  }) = _HabitLog;

  factory HabitLog.fromJson(Map<String, dynamic> json) => _$HabitLogFromJson(json);
}
