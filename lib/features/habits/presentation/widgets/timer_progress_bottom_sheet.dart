import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_duration.dart';
import '../../domain/entities/habit_log.dart';
import '../extensions/habit_color_extension.dart';
import '../extensions/habit_icon_extension.dart';
import '../providers/timer_countdown_notifier.dart';

/// Modal bottom sheet for countdown timer habits.
/// Operates like a native Android countdown timer: counts down to 00:00,
/// auto-completes on zero, and transitions buttons cleanly (Start -> Pause/Reset -> Resume/Reset -> Completed).
class TimerProgressBottomSheet extends ConsumerWidget {
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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimerProgressBottomSheet(
        habit: habit,
        initialLog: initialLog,
        targetDate: targetDate,
      ),
    );
  }

  String _formatCountdownClock(int seconds) {
    if (seconds <= 0) return '00:00';
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hrs > 0) {
      return '${hrs.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = TimerCountdownParams(
      habit: habit,
      initialLog: initialLog,
      targetDate: targetDate,
    );
    final state = ref.watch(timerCountdownProvider(params));
    final notifier = ref.read(timerCountdownProvider(params).notifier);

    final theme = Theme.of(context);
    final accentColor = habit.color.color;
    final mediaQuery = MediaQuery.of(context);

    final targetDurationStr = HabitDuration(state.targetSeconds).formatted();
    final remainingDurationStr = HabitDuration(state.remainingSeconds).formatted();
    final clockDisplayStr = _formatCountdownClock(state.remainingSeconds);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
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
              const SizedBox(height: 16),
              // Body Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                              habit.icon.toIconData,
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
                                  habit.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  state.status == TimerCountdownStatus.completed
                                      ? 'Completed of $targetDurationStr'
                                      : '$remainingDurationStr remaining of $targetDurationStr',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Close timer bottom sheet',
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              tooltip: 'Cancel',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Countdown Clock Display
                      Center(
                        child: Semantics(
                          label: 'Remaining time $clockDisplayStr',
                          child: Text(
                            clockDisplayStr,
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Controls based on TimerCountdownStatus
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildControlsRow(
                          context: context,
                          status: state.status,
                          accentColor: accentColor,
                          notifier: notifier,
                          isSubmitting: state.isSubmitting,
                        ),
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsRow({
    required BuildContext context,
    required TimerCountdownStatus status,
    required Color accentColor,
    required TimerCountdownNotifier notifier,
    required bool isSubmitting,
  }) {
    final theme = Theme.of(context);

    switch (status) {
      case TimerCountdownStatus.initial:
        return Center(
          key: const ValueKey('initial_controls'),
          child: Semantics(
            button: true,
            label: 'Start timer',
            child: FilledButton.icon(
              onPressed: notifier.start,
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_arrow, size: 28),
              label: Text(
                'Start',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );

      case TimerCountdownStatus.running:
        return Row(
          key: const ValueKey('running_controls'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              label: 'Pause timer',
              child: FilledButton.tonalIcon(
                onPressed: notifier.pause,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.pause, size: 24),
                label: const Text('Pause'),
              ),
            ),
            const SizedBox(width: 16),
            Semantics(
              button: true,
              label: 'Reset timer',
              child: OutlinedButton.icon(
                onPressed: notifier.reset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text('Reset'),
              ),
            ),
          ],
        );

      case TimerCountdownStatus.paused:
        return Row(
          key: const ValueKey('paused_controls'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              button: true,
              label: 'Resume timer',
              child: FilledButton.icon(
                onPressed: notifier.start,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.play_arrow, size: 24),
                label: Text(
                  'Resume',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Semantics(
              button: true,
              label: 'Reset timer',
              child: OutlinedButton.icon(
                onPressed: notifier.reset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text('Reset'),
              ),
            ),
          ],
        );

      case TimerCountdownStatus.completed:
        return Column(
          key: const ValueKey('completed_controls'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade800, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Completed! 🎉',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'Dismiss completed timer',
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Done'),
              ),
            ),
          ],
        );
    }
  }
}
