import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/notifications/notification_provider.dart';
import '../../../settings/presentation/providers/vacation_mode_provider.dart';
import '../../domain/usecases/archive_habit_use_case.dart';
import '../../domain/usecases/cancel_habit_reminders_use_case.dart';
import '../../domain/usecases/calculate_streak_use_case.dart';
import '../../domain/usecases/create_habit_use_case.dart';
import '../../domain/usecases/delete_habit_use_case.dart';
import '../../domain/usecases/get_daily_completion_use_case.dart';
import '../../domain/usecases/log_habit_progress_use_case.dart';
import '../../domain/usecases/reconcile_reminders_use_case.dart';
import '../../domain/usecases/restore_habit_use_case.dart';
import '../../domain/usecases/schedule_habit_reminders_use_case.dart';
import '../../domain/usecases/update_habit_use_case.dart';
import 'habit_providers.dart';

final scheduleHabitRemindersUseCaseProvider =
    Provider<ScheduleHabitRemindersUseCase>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final vacationRepo = ref.watch(vacationModeRepositoryProvider);
  return ScheduleHabitRemindersUseCase(notificationService, vacationRepo);
});

final cancelHabitRemindersUseCaseProvider =
    Provider<CancelHabitRemindersUseCase>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return CancelHabitRemindersUseCase(notificationService);
});

final createHabitUseCaseProvider = Provider<CreateHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final scheduleReminders = ref.watch(scheduleHabitRemindersUseCaseProvider);
  return CreateHabitUseCase(repository, scheduleReminders);
});

final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final scheduleReminders = ref.watch(scheduleHabitRemindersUseCaseProvider);
  final cancelReminders = ref.watch(cancelHabitRemindersUseCaseProvider);
  return UpdateHabitUseCase(repository, scheduleReminders, cancelReminders);
});

final archiveHabitUseCaseProvider = Provider<ArchiveHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final cancelReminders = ref.watch(cancelHabitRemindersUseCaseProvider);
  return ArchiveHabitUseCase(repository, cancelReminders);
});

final restoreHabitUseCaseProvider = Provider<RestoreHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final scheduleReminders = ref.watch(scheduleHabitRemindersUseCaseProvider);
  return RestoreHabitUseCase(repository, scheduleReminders);
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final cancelReminders = ref.watch(cancelHabitRemindersUseCaseProvider);
  return DeleteHabitUseCase(repository, cancelReminders);
});

final logHabitProgressUseCaseProvider = Provider<LogHabitProgressUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return LogHabitProgressUseCase(repository);
});

final calculateStreakUseCaseProvider = Provider<CalculateStreakUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return CalculateStreakUseCase(repository);
});

final getDailyCompletionUseCaseProvider =
    Provider<GetDailyCompletionUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return GetDailyCompletionUseCase(repository);
});

final reconcileRemindersUseCaseProvider =
    Provider<ReconcileRemindersUseCase>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final scheduleReminders = ref.watch(scheduleHabitRemindersUseCaseProvider);
  return ReconcileRemindersUseCase(repository, scheduleReminders);
});
