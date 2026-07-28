import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_frequency.dart';
import '../../../habits/domain/entities/habit_log.dart';
import '../../../habits/domain/entities/habit_type.dart';
import '../../../habits/presentation/extensions/habit_color_extension.dart';
import '../../../habits/presentation/extensions/habit_icon_extension.dart';
import '../../../habits/presentation/providers/habit_completion_provider.dart';
import '../../../habits/presentation/providers/streak_provider.dart';
import '../../../habits/presentation/providers/use_case_providers.dart';
import '../../../habits/presentation/widgets/numeric_progress_bottom_sheet.dart';
import '../../../habits/presentation/widgets/timer_progress_bottom_sheet.dart';
import '../../../settings/presentation/providers/vacation_mode_provider.dart';
import 'streak_badge.dart';

/// Material 3 Habit Card widget with interactive quick completion toggle.
class HabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
  });

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard> {
  bool _isLoading = false;

  String _formatFrequency(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }

  String _formatHabitType(HabitType type) {
    switch (type) {
      case HabitType.boolean:
        return 'Yes/No';
      case HabitType.numeric:
        return 'Numeric';
      case HabitType.timer:
        return 'Timer';
    }
  }

  String? _formatTargetValue(Habit habit, int currentValue) {
    switch (habit.habitType) {
      case HabitType.numeric:
        return '$currentValue / ${habit.targetCount}';
      case HabitType.timer:
        return '${currentValue}m / ${habit.targetCount} mins';
      case HabitType.boolean:
        return null;
    }
  }

  Future<void> _toggleBooleanCompletion(bool currentlyCompleted) async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    try {
      final useCase = ref.read(logHabitProgressUseCaseProvider);
      final newStatus = currentlyCompleted
          ? HabitLogStatus.failed
          : HabitLogStatus.completed;
      final newValue = currentlyCompleted ? 0 : 1;

      await useCase.execute(
        habitId: widget.habit.id,
        status: newStatus,
        value: newValue,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update habit progress: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCardTapped(BuildContext context, HabitLog? currentLog) {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    switch (widget.habit.habitType) {
      case HabitType.boolean:
        final isCompleted = currentLog?.status == HabitLogStatus.completed;
        _toggleBooleanCompletion(isCompleted);
        break;
      case HabitType.numeric:
        NumericProgressBottomSheet.show(
          context,
          habit: widget.habit,
          initialLog: currentLog,
        );
        break;
      case HabitType.timer:
        TimerProgressBottomSheet.show(
          context,
          habit: widget.habit,
          initialLog: currentLog,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.habit.color.color;
    final frequencyText = _formatFrequency(widget.habit.frequency);
    final typeText = _formatHabitType(widget.habit.habitType);

    final asyncTodayLogs = ref.watch(todayLogsStreamProvider);
    final logs = asyncTodayLogs.valueOrNull ?? [];
    HabitLog? currentLog;
    for (final l in logs) {
      if (l.habitId == widget.habit.id) {
        currentLog = l;
        break;
      }
    }

    final asyncStreak = ref.watch(streakProvider(widget.habit.id));
    final streak = asyncStreak.valueOrNull;
    final currentStreak = streak?.currentStreak ?? 0;
    final isVacationModeActive = ref.watch(vacationModeProvider);
    final isProtected = isVacationModeActive || currentLog?.isFrozen == true;

    final currentValue = currentLog?.currentValue ?? 0;
    final isCompleted = currentLog?.status == HabitLogStatus.completed;
    final targetText = _formatTargetValue(widget.habit, currentValue);

    return Semantics(
      label:
          'Habit ${widget.habit.title}, $frequencyText frequency, $typeText type, streak $currentStreak days${targetText != null ? ', $targetText' : ''}, ${isCompleted ? 'completed' : 'not completed'}',
      button: true,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isCompleted
                ? accentColor.withValues(alpha: 0.5)
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isCompleted ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onCardTapped(context, currentLog),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Color accent & Icon avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? accentColor
                        : accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.habit.icon.toIconData,
                    color: isCompleted ? Colors.white : accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.habit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.habit.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.habit.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Metadata chips row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StreakBadge(
                            streakCount: currentStreak,
                            isProtected: isProtected,
                          ),
                          _MetaBadge(
                            label: frequencyText,
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            foregroundColor:
                                theme.colorScheme.onSecondaryContainer,
                          ),
                          _MetaBadge(
                            label: typeText,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHigh,
                            foregroundColor:
                                theme.colorScheme.onSurfaceVariant,
                          ),
                          if (targetText != null)
                            _MetaBadge(
                              label: targetText,
                              backgroundColor:
                                  accentColor.withValues(alpha: 0.1),
                              foregroundColor: accentColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Quick Completion Toggle Button
                _CompletionToggle(
                  habit: widget.habit,
                  isCompleted: isCompleted,
                  isLoading: _isLoading,
                  accentColor: accentColor,
                  onToggle: () {
                    if (widget.habit.habitType == HabitType.boolean) {
                      _toggleBooleanCompletion(isCompleted);
                    } else {
                      _onCardTapped(context, currentLog);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _CompletionToggle extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final bool isLoading;
  final Color accentColor;
  final VoidCallback onToggle;

  const _CompletionToggle({
    required this.habit,
    required this.isCompleted,
    required this.isLoading,
    required this.accentColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: accentColor,
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      checked: isCompleted,
      label: 'Toggle ${habit.title} completion',
      child: IconButton(
        onPressed: onToggle,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: isCompleted
              ? Icon(
                  Icons.check_circle,
                  key: const ValueKey('completed'),
                  color: accentColor,
                  size: 32,
                )
              : Icon(
                  Icons.circle_outlined,
                  key: const ValueKey('uncompleted'),
                  color: Theme.of(context).colorScheme.outline,
                  size: 32,
                ),
        ),
        tooltip: isCompleted ? 'Completed (Tap to undo)' : 'Mark Completed',
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _MetaBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
