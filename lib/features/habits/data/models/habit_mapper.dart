import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_color.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/entities/habit_type.dart';

class HabitMapper {
  static Habit toEntity(HabitTableData data) {
    return Habit(
      id: data.id,
      title: data.title,
      description: data.description,
      icon: data.icon,
      color: HabitColor.values.firstWhere(
        (c) => c.name == data.color,
        orElse: () => HabitColor.blue,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (f) => f.name == data.frequency,
        orElse: () => HabitFrequency.daily,
      ),
      habitType: HabitType.values.firstWhere(
        (t) => t.name == data.habitType,
        orElse: () => HabitType.boolean,
      ),
      targetCount: data.targetCount,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isArchived: data.isArchived,
      reminderTime: data.reminderTime,
      isReminderEnabled: data.isReminderEnabled,
    );
  }

  static HabitsCompanion toCompanion(Habit entity) {
    return HabitsCompanion.insert(
      id: entity.id,
      title: entity.title,
      description: Value(entity.description),
      icon: Value(entity.icon),
      color: entity.color.name,
      frequency: entity.frequency.name,
      habitType: entity.habitType.name,
      targetCount: Value(entity.targetCount),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isArchived: Value(entity.isArchived),
      reminderTime: Value(entity.reminderTime),
      isReminderEnabled: Value(entity.isReminderEnabled),
    );
  }
}
