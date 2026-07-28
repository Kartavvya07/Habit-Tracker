import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_info.freezed.dart';
part 'streak_info.g.dart';

@freezed
class StreakInfo with _$StreakInfo {
  const factory StreakInfo({
    @Default(0) int currentStreak,
    @Default(0) int bestStreak,
    @Default(0.0) double completionRate,
    @Default(0) int totalCompleted,
    @Default(0) int totalScheduled,
  }) = _StreakInfo;

  factory StreakInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakInfoFromJson(json);
}
