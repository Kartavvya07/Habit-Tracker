// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_completion_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyCompletionStatsImpl _$$DailyCompletionStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyCompletionStatsImpl(
      date: DateTime.parse(json['date'] as String),
      totalHabits: (json['totalHabits'] as num?)?.toInt() ?? 0,
      completedHabits: (json['completedHabits'] as num?)?.toInt() ?? 0,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      isFullyCompleted: json['isFullyCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$DailyCompletionStatsImplToJson(
        _$DailyCompletionStatsImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalHabits': instance.totalHabits,
      'completedHabits': instance.completedHabits,
      'completionPercentage': instance.completionPercentage,
      'isFullyCompleted': instance.isFullyCompleted,
    };
