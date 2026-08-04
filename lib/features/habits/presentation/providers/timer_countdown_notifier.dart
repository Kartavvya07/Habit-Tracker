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
  final int elapsedSecondsBeforeStart;
  final DateTime? startTimestamp;
  final TimerCountdownStatus status;
  final bool isSubmitting;
  final String? errorMessage;

  const TimerCountdownState({
    required this.remainingSeconds,
    required this.targetSeconds,
    this.elapsedSecondsBeforeStart = 0,
    this.startTimestamp,
    this.status = TimerCountdownStatus.initial,
    this.isSubmitting = false,
    this.errorMessage,
  });

  TimerCountdownState copyWith({
    int? remainingSeconds,
    int? targetSeconds,
    int? elapsedSecondsBeforeStart,
    ValueGetter<DateTime?>? startTimestamp,
    TimerCountdownStatus? status,
    bool? isSubmitting,
    ValueGetter<String?>? errorMessage,
  }) {
    return TimerCountdownState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      elapsedSecondsBeforeStart:
          elapsedSecondsBeforeStart ?? this.elapsedSecondsBeforeStart,
      startTimestamp:
          startTimestamp != null ? startTimestamp() : this.startTimestamp,
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

final timerCountdownProvider = NotifierProviderFamily<
    TimerCountdownNotifier, TimerCountdownState, TimerCountdownParams>(
  TimerCountdownNotifier.new,
);

class TimerCountdownNotifier
    extends FamilyNotifier<TimerCountdownState, TimerCountdownParams> {
  Timer? _timer;
  int _ticksSinceStart = 0;

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
        elapsedSecondsBeforeStart: target,
        status: TimerCountdownStatus.completed,
      );
    }

    final elapsed = arg.initialLog?.currentValue ?? 0;
    final remaining = (target - elapsed).clamp(0, target);

    if (remaining <= 0) {
      return TimerCountdownState(
        remainingSeconds: 0,
        targetSeconds: target,
        elapsedSecondsBeforeStart: target,
        status: TimerCountdownStatus.completed,
      );
    }

    final initialStatus =
        elapsed > 0 ? TimerCountdownStatus.paused : TimerCountdownStatus.initial;

    return TimerCountdownState(
      remainingSeconds: remaining,
      targetSeconds: target,
      elapsedSecondsBeforeStart: elapsed,
      status: initialStatus,
    );
  }

  void start() {
    if (state.status == TimerCountdownStatus.running) return;
    HapticFeedback.lightImpact();

    _timer?.cancel();
    _ticksSinceStart = 0;
    final now = DateTime.now();
    state = state.copyWith(
      status: TimerCountdownStatus.running,
      startTimestamp: () => now,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.status != TimerCountdownStatus.running) {
      return;
    }

    _ticksSinceStart += 1;
    final realElapsed = state.startTimestamp != null
        ? DateTime.now().difference(state.startTimestamp!).inSeconds
        : 0;
    final elapsedSinceStart =
        realElapsed > _ticksSinceStart ? realElapsed : _ticksSinceStart;
    final totalElapsed = state.elapsedSecondsBeforeStart + elapsedSinceStart;
    final remaining = (state.targetSeconds - totalElapsed).clamp(0, state.targetSeconds);

    if (remaining <= 0) {
      _timer?.cancel();
      state = state.copyWith(
        remainingSeconds: 0,
        status: TimerCountdownStatus.completed,
        startTimestamp: () => null,
        elapsedSecondsBeforeStart: state.targetSeconds,
      );
      _completeHabit();
    } else {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  void pause() {
    if (state.status != TimerCountdownStatus.running) return;
    HapticFeedback.lightImpact();

    _timer?.cancel();
    final realElapsed = state.startTimestamp != null
        ? DateTime.now().difference(state.startTimestamp!).inSeconds
        : 0;
    final elapsedSinceStart =
        realElapsed > _ticksSinceStart ? realElapsed : _ticksSinceStart;
    final totalElapsed = state.elapsedSecondsBeforeStart + elapsedSinceStart;
    final remaining = (state.targetSeconds - totalElapsed).clamp(0, state.targetSeconds);

    state = state.copyWith(
      status: TimerCountdownStatus.paused,
      startTimestamp: () => null,
      elapsedSecondsBeforeStart: totalElapsed,
      remainingSeconds: remaining,
    );
    _ticksSinceStart = 0;
  }

  void reset() {
    HapticFeedback.mediumImpact();

    _timer?.cancel();
    _ticksSinceStart = 0;
    state = state.copyWith(
      remainingSeconds: state.targetSeconds,
      elapsedSecondsBeforeStart: 0,
      startTimestamp: () => null,
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
