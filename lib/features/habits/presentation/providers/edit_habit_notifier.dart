import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_color.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/entities/habit_type.dart';
import 'create_habit_state.dart';
import 'edit_habit_state.dart';
import 'use_case_providers.dart';

class EditHabitNotifier
    extends AutoDisposeFamilyNotifier<EditHabitState, Habit> {
  @override
  EditHabitState build(Habit arg) {
    return EditHabitState.fromHabit(arg);
  }

  void updateTitle(String title) {
    state = state.copyWith(
      title: title,
      titleError: () => null,
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateIcon(String icon) {
    state = state.copyWith(icon: icon);
  }

  void updateColor(HabitColor color) {
    state = state.copyWith(color: color);
  }

  void updateFrequency(HabitFrequency frequency) {
    state = state.copyWith(frequency: frequency);
  }

  void updateHabitType(HabitType habitType) {
    final newTarget = habitType == HabitType.boolean ? 1 : state.targetCount;
    state = state.copyWith(
      habitType: habitType,
      targetCount: newTarget,
      targetCountError: () => null,
    );
  }

  void updateTargetCount(int targetCount) {
    state = state.copyWith(
      targetCount: targetCount,
      targetCountError: () => null,
    );
  }

  bool validate() {
    String? titleErr;
    String? targetCountErr;

    if (state.title.trim().isEmpty) {
      titleErr = 'Title cannot be empty';
    }

    if (state.targetCount <= 0) {
      targetCountErr = 'Target count must be greater than 0';
    }

    state = state.copyWith(
      titleError: () => titleErr,
      targetCountError: () => targetCountErr,
    );

    return titleErr == null && targetCountErr == null;
  }

  Future<bool> saveHabit() async {
    if (state.isSubmitting) return false;

    if (!validate()) {
      return false;
    }

    state = state.copyWith(
      status: FormSubmissionStatus.submitting,
      errorMessage: () => null,
    );

    try {
      final now = DateTime.now();
      final updatedHabit = Habit(
        id: state.habitId,
        title: state.title.trim(),
        description: state.description.trim(),
        icon: state.icon,
        color: state.color,
        frequency: state.frequency,
        habitType: state.habitType,
        targetCount: state.targetCount,
        createdAt: state.createdAt,
        updatedAt: now,
        isArchived: state.isArchived,
      );

      final updateHabitUseCase = ref.read(updateHabitUseCaseProvider);
      await updateHabitUseCase.execute(updatedHabit);

      state = state.copyWith(status: FormSubmissionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FormSubmissionStatus.failure,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  Future<bool> archiveHabit() async {
    if (state.isSubmitting) return false;

    state = state.copyWith(
      status: FormSubmissionStatus.submitting,
      errorMessage: () => null,
    );

    try {
      final archiveHabitUseCase = ref.read(archiveHabitUseCaseProvider);
      await archiveHabitUseCase.execute(state.habitId);

      state = state.copyWith(
        isArchived: true,
        status: FormSubmissionStatus.success,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FormSubmissionStatus.failure,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  Future<bool> restoreHabit() async {
    if (state.isSubmitting) return false;

    state = state.copyWith(
      status: FormSubmissionStatus.submitting,
      errorMessage: () => null,
    );

    try {
      final restoreHabitUseCase = ref.read(restoreHabitUseCaseProvider);
      await restoreHabitUseCase.execute(state.habitId);

      state = state.copyWith(
        isArchived: false,
        status: FormSubmissionStatus.success,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FormSubmissionStatus.failure,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteHabit() async {
    if (state.isSubmitting) return false;

    state = state.copyWith(
      status: FormSubmissionStatus.submitting,
      errorMessage: () => null,
    );

    try {
      final deleteHabitUseCase = ref.read(deleteHabitUseCaseProvider);
      await deleteHabitUseCase.execute(state.habitId);

      state = state.copyWith(status: FormSubmissionStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: FormSubmissionStatus.failure,
        errorMessage: () => e.toString(),
      );
      return false;
    }
  }
}

final editHabitProvider = NotifierProvider.autoDispose
    .family<EditHabitNotifier, EditHabitState, Habit>(
  EditHabitNotifier.new,
);
