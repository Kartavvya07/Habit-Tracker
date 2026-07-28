// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitLogImpl _$$HabitLogImplFromJson(Map<String, dynamic> json) =>
    _$HabitLogImpl(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      status: $enumDecodeNullable(_$HabitLogStatusEnumMap, json['status']) ??
          HabitLogStatus.completed,
      currentValue: (json['currentValue'] as num?)?.toInt() ?? 0,
      isFrozen: json['isFrozen'] as bool? ?? false,
    );

Map<String, dynamic> _$$HabitLogImplToJson(_$HabitLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'habitId': instance.habitId,
      'targetDate': instance.targetDate.toIso8601String(),
      'status': _$HabitLogStatusEnumMap[instance.status]!,
      'currentValue': instance.currentValue,
      'isFrozen': instance.isFrozen,
    };

const _$HabitLogStatusEnumMap = {
  HabitLogStatus.completed: 'completed',
  HabitLogStatus.skipped: 'skipped',
  HabitLogStatus.failed: 'failed',
  HabitLogStatus.inProgress: 'inProgress',
};
