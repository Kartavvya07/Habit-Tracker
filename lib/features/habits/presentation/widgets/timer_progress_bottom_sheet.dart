import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../extensions/habit_color_extension.dart';
import '../extensions/habit_icon_extension.dart';
import '../providers/use_case_providers.dart';

/// Modal bottom sheet for logging progress on timer habits.
class TimerProgressBottomSheet extends ConsumerStatefulWidget {
  final Habit habit;
  final HabitLog? initialLog;
  final DateTime? targetDate;

  const TimerProgressBottomSheet({
    super.key,
    required this.habit,
    this.initialLog,
    this.targetDate,
  });

  static Future<void> show(
    BuildContext context, {
    required Habit habit,
    HabitLog? initialLog,
    DateTime? targetDate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimerProgressBottomSheet(
        habit: habit,
        initialLog: initialLog,
        targetDate: targetDate,
      ),
    );
  }

  @override
  ConsumerState<TimerProgressBottomSheet> createState() =>
      _TimerProgressBottomSheetState();
}

class _TimerProgressBottomSheetState
    extends ConsumerState<TimerProgressBottomSheet> {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialMinutes = widget.initialLog?.currentValue ?? 0;
    _secondsElapsed = initialMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    setState(() {
      _secondsElapsed = 0;
      _isRunning = false;
    });
  }

  void _addMinutes(int minutes) {
    HapticFeedback.lightImpact();
    setState(() {
      _secondsElapsed = (_secondsElapsed + minutes * 60).clamp(0, 86400);
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    _pauseTimer();
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.mediumImpact();
      final minutesCompleted = (_secondsElapsed / 60).round();
      final useCase = ref.read(logHabitProgressUseCaseProvider);
      await useCase.execute(
        habitId: widget.habit.id,
        targetDate: widget.targetDate,
        value: minutesCompleted,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.habit.color.color;
    final targetMinutes = widget.habit.targetCount;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.habit.icon.toIconData,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Target: $targetMinutes mins',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Close timer progress log',
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Cancel',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Timer Display
              Center(
                child: Semantics(
                  label: 'Elapsed time ${_formatTime(_secondsElapsed)}',
                  child: Text(
                    _formatTime(_secondsElapsed),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Timer Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    button: true,
                    label: 'Reset timer',
                    child: IconButton.filledTonal(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset Timer',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Semantics(
                    button: true,
                    label: _isRunning ? 'Pause timer' : 'Start timer',
                    child: FloatingActionButton.large(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      backgroundColor: accentColor,
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Semantics(
                    button: true,
                    label: 'Add 5 minutes to timer',
                    child: IconButton.filledTonal(
                      onPressed: () => _addMinutes(5),
                      icon: const Icon(Icons.add),
                      tooltip: 'Add 5 Mins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quick Add Minute Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    button: true,
                    label: 'Add 1 minute to timer',
                    child: ActionChip(
                      label: const Text('+1 Min'),
                      onPressed: () => _addMinutes(1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: 'Add 5 minutes to timer',
                    child: ActionChip(
                      label: const Text('+5 Mins'),
                      onPressed: () => _addMinutes(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: 'Add 10 minutes to timer',
                    child: ActionChip(
                      label: const Text('+10 Mins'),
                      onPressed: () => _addMinutes(10),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              // Save Button
              Semantics(
                button: true,
                label: 'Save timer progress',
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: accentColor,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Progress'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
