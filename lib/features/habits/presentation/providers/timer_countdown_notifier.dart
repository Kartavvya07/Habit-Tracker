import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import 'use_case_providers.dart';

enum TimerCountdownStatus {
  initial,
  running,
  paused,
  completed,
}

@immutable
class TimerCountdownState {
  final int remainingSeconds;
  final int targetSeconds;
  final TimerCountdownStatus status;
  final bool isSubmitting;
  final String? errorMessage;

  const TimerCountdownState({
    required this.remainingSeconds,
    required this.targetSeconds,
    this.status = TimerCountdownStatus.initial,
    this.isSubmitting = false,
    this.errorMessage,
  });

  TimerCountdownState copyWith({
    int? remainingSeconds,
    int? targetSeconds,
    TimerCountdownStatus? status,
    bool? isSubmitting,
    ValueGetter<String?>? errorMessage,
  }) {
    return TimerCountdownState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class TimerCountdownParams {
  final Habit habit;
  final HabitLog? initialLog;
  final DateTime? targetDate;

  const TimerCountdownParams({
    required this.habit,
    this.initialLog,
    this.targetDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerCountdownParams &&
          habit.id == other.habit.id &&
          initialLog?.id == other.initialLog?.id &&
          targetDate == other.targetDate;

  @override
  int get hashCode => Object.hash(habit.id, initialLog?.id, targetDate);
}

final timerCountdownProvider = AutoDisposeNotifierProviderFamily<
    TimerCountdownNotifier, TimerCountdownState, TimerCountdownParams>(
  TimerCountdownNotifier.new,
);

class TimerCountdownNotifier
    extends AutoDisposeFamilyNotifier<TimerCountdownState, TimerCountdownParams> {
  Timer? _timer;

  @override
  TimerCountdownState build(TimerCountdownParams arg) {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final target = arg.habit.targetCount > 0 ? arg.habit.targetCount : 1;
    final isAlreadyCompleted = arg.initialLog?.status == HabitLogStatus.completed ||
        (arg.initialLog != null && arg.initialLog!.currentValue >= target);

    if (isAlreadyCompleted) {
      return TimerCountdownState(
        remainingSeconds: 0,
        targetSeconds: target,
        status: TimerCountdownStatus.completed,
      );
    }

    final elapsed = arg.initialLog?.currentValue ?? 0;
    final remaining = (target - elapsed).clamp(0, target);

    if (remaining <= 0) {
      return TimerCountdownState(
        remainingSeconds: 0,
        targetSeconds: target,
        status: TimerCountdownStatus.completed,
      );
    }

    final initialStatus =
        elapsed > 0 ? TimerCountdownStatus.paused : TimerCountdownStatus.initial;

    return TimerCountdownState(
      remainingSeconds: remaining,
      targetSeconds: target,
      status: initialStatus,
    );
  }

  void start() {
    if (state.status == TimerCountdownStatus.running) return;
    HapticFeedback.lightImpact();

    _timer?.cancel();
    state = state.copyWith(status: TimerCountdownStatus.running);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(
          remainingSeconds: 0,
          status: TimerCountdownStatus.completed,
        );
        _completeHabit();
      }
    });
  }

  void pause() {
    if (state.status != TimerCountdownStatus.running) return;
    HapticFeedback.lightImpact();

    _timer?.cancel();
    state = state.copyWith(status: TimerCountdownStatus.paused);
  }

  void reset() {
    HapticFeedback.mediumImpact();

    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: state.targetSeconds,
      status: TimerCountdownStatus.initial,
      errorMessage: () => null,
    );
  }

  Future<void> _completeHabit() async {
    state = state.copyWith(isSubmitting: true);
    try {
      HapticFeedback.heavyImpact();
      final useCase = ref.read(logHabitProgressUseCaseProvider);
      await useCase.execute(
        habitId: arg.habit.id,
        targetDate: arg.targetDate,
        value: state.targetSeconds,
      );
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => e.toString(),
      );
    }
  }
}
