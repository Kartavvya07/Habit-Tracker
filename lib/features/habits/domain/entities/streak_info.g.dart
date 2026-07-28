// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakInfoImpl _$$StreakInfoImplFromJson(Map<String, dynamic> json) =>
    _$StreakInfoImpl(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      totalCompleted: (json['totalCompleted'] as num?)?.toInt() ?? 0,
      totalScheduled: (json['totalScheduled'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StreakInfoImplToJson(_$StreakInfoImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'bestStreak': instance.bestStreak,
      'completionRate': instance.completionRate,
      'totalCompleted': instance.totalCompleted,
      'totalScheduled': instance.totalScheduled,
    };
