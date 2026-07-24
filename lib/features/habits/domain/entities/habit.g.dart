// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitImpl _$$HabitImplFromJson(Map<String, dynamic> json) => _$HabitImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'check',
      color: $enumDecodeNullable(_$HabitColorEnumMap, json['color']) ??
          HabitColor.blue,
      frequency:
          $enumDecodeNullable(_$HabitFrequencyEnumMap, json['frequency']) ??
              HabitFrequency.daily,
      habitType: $enumDecodeNullable(_$HabitTypeEnumMap, json['habitType']) ??
          HabitType.boolean,
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isArchived: json['isArchived'] as bool? ?? false,
    );

Map<String, dynamic> _$$HabitImplToJson(_$HabitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'color': _$HabitColorEnumMap[instance.color]!,
      'frequency': _$HabitFrequencyEnumMap[instance.frequency]!,
      'habitType': _$HabitTypeEnumMap[instance.habitType]!,
      'targetCount': instance.targetCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isArchived': instance.isArchived,
    };

const _$HabitColorEnumMap = {
  HabitColor.blue: 'blue',
  HabitColor.green: 'green',
  HabitColor.purple: 'purple',
  HabitColor.orange: 'orange',
  HabitColor.red: 'red',
  HabitColor.teal: 'teal',
  HabitColor.pink: 'pink',
  HabitColor.indigo: 'indigo',
};

const _$HabitFrequencyEnumMap = {
  HabitFrequency.daily: 'daily',
  HabitFrequency.weekly: 'weekly',
  HabitFrequency.monthly: 'monthly',
};

const _$HabitTypeEnumMap = {
  HabitType.boolean: 'boolean',
  HabitType.numeric: 'numeric',
  HabitType.timer: 'timer',
};
