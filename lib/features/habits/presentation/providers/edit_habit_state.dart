import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_color.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/entities/habit_type.dart';
import 'create_habit_state.dart';

class EditHabitState {
  final String habitId;
  final String title;
  final String description;
  final String icon;
  final HabitColor color;
  final HabitFrequency frequency;
  final HabitType habitType;
  final int targetCount;
  final DateTime createdAt;
  final bool isArchived;
  final String? titleError;
  final String? targetCountError;
  final FormSubmissionStatus status;
  final String? errorMessage;

  const EditHabitState({
    required this.habitId,
    this.title = '',
    this.description = '',
    this.icon = 'check',
    this.color = HabitColor.blue,
    this.frequency = HabitFrequency.daily,
    this.habitType = HabitType.boolean,
    this.targetCount = 1,
    required this.createdAt,
    this.isArchived = false,
    this.titleError,
    this.targetCountError,
    this.status = FormSubmissionStatus.initial,
    this.errorMessage,
  });

  factory EditHabitState.fromHabit(Habit habit) {
    return EditHabitState(
      habitId: habit.id,
      title: habit.title,
      description: habit.description,
      icon: habit.icon,
      color: habit.color,
      frequency: habit.frequency,
      habitType: habit.habitType,
      targetCount: habit.targetCount,
      createdAt: habit.createdAt,
      isArchived: habit.isArchived,
    );
  }

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  EditHabitState copyWith({
    String? title,
    String? description,
    String? icon,
    HabitColor? color,
    HabitFrequency? frequency,
    HabitType? habitType,
    int? targetCount,
    bool? isArchived,
    String? Function()? titleError,
    String? Function()? targetCountError,
    FormSubmissionStatus? status,
    String? Function()? errorMessage,
  }) {
    return EditHabitState(
      habitId: habitId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      habitType: habitType ?? this.habitType,
      targetCount: targetCount ?? this.targetCount,
      createdAt: createdAt,
      isArchived: isArchived ?? this.isArchived,
      titleError: titleError != null ? titleError() : this.titleError,
      targetCountError:
          targetCountError != null ? targetCountError() : this.targetCountError,
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
