import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_completion_stats.freezed.dart';
part 'daily_completion_stats.g.dart';

@freezed
class DailyCompletionStats with _$DailyCompletionStats {
  const factory DailyCompletionStats({
    required DateTime date,
    @Default(0) int totalHabits,
    @Default(0) int completedHabits,
    @Default(0.0) double completionPercentage,
    @Default(false) bool isFullyCompleted,
  }) = _DailyCompletionStats;

  factory DailyCompletionStats.fromJson(Map<String, dynamic> json) =>
      _$DailyCompletionStatsFromJson(json);
}
