import 'package:freezed_annotation/freezed_annotation.dart';
import 'habit_color.dart';
import 'habit_frequency.dart';
import 'habit_type.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

@freezed
class Habit with _$Habit {
  const factory Habit({
    required String id,
    required String title,
    @Default('') String description,
    @Default('check') String icon,
    @Default(HabitColor.blue) HabitColor color,
    @Default(HabitFrequency.daily) HabitFrequency frequency,
    @Default(HabitType.boolean) HabitType habitType,
    @Default(1) int targetCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isArchived,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}
