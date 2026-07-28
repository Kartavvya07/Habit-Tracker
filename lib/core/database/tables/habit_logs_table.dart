import 'package:drift/drift.dart';
import 'habits_table.dart';

@DataClassName('HabitLogTableData')
@TableIndex(name: 'idx_habit_logs_habit_target_date', columns: {#habitId, #targetDate})
class HabitLogs extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get targetDate => dateTime()();
  TextColumn get status => text()();
  IntColumn get currentValue => integer().withDefault(const Constant(0))();
  BoolColumn get isFrozen => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
