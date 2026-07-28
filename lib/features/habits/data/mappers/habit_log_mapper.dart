import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/habit_log.dart';

class HabitLogMapper {
  static HabitLog toEntity(HabitLogTableData data) {
    return HabitLog(
      id: data.id,
      habitId: data.habitId,
      targetDate: data.targetDate,
      status: HabitLogStatus.values.firstWhere(
        (s) => s.name == data.status,
        orElse: () => HabitLogStatus.completed,
      ),
      currentValue: data.currentValue,
      isFrozen: data.isFrozen,
    );
  }

  static HabitLogsCompanion toCompanion(HabitLog entity) {
    return HabitLogsCompanion.insert(
      id: entity.id,
      habitId: entity.habitId,
      targetDate: entity.targetDate,
      status: entity.status.name,
      currentValue: Value(entity.currentValue),
      isFrozen: Value(entity.isFrozen),
    );
  }
}
