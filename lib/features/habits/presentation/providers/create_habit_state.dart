import '../../domain/entities/habit_color.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/entities/habit_type.dart';

enum FormSubmissionStatus { initial, submitting, success, failure }

class CreateHabitState {
  final String title;
  final String description;
  final String icon;
  final HabitColor color;
  final HabitFrequency frequency;
  final HabitType habitType;
  final int targetCount;
  final String? titleError;
  final String? targetCountError;
  final FormSubmissionStatus status;
  final String? errorMessage;

  final bool isReminderEnabled;
  final String? reminderTime;

  const CreateHabitState({
    this.title = '',
    this.description = '',
    this.icon = 'check',
    this.color = HabitColor.blue,
    this.frequency = HabitFrequency.daily,
    this.habitType = HabitType.boolean,
    this.targetCount = 1,
    this.isReminderEnabled = false,
    this.reminderTime,
    this.titleError,
    this.targetCountError,
    this.status = FormSubmissionStatus.initial,
    this.errorMessage,
  });

  bool get isSubmitting => status == FormSubmissionStatus.submitting;

  CreateHabitState copyWith({
    String? title,
    String? description,
    String? icon,
    HabitColor? color,
    HabitFrequency? frequency,
    HabitType? habitType,
    int? targetCount,
    bool? isReminderEnabled,
    String? Function()? reminderTime,
    String? Function()? titleError,
    String? Function()? targetCountError,
    FormSubmissionStatus? status,
    String? Function()? errorMessage,
  }) {
    return CreateHabitState(
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      habitType: habitType ?? this.habitType,
      targetCount: targetCount ?? this.targetCount,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderTime: reminderTime != null ? reminderTime() : this.reminderTime,
      titleError: titleError != null ? titleError() : this.titleError,
      targetCountError:
          targetCountError != null ? targetCountError() : this.targetCountError,
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
