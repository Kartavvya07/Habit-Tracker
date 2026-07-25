import 'package:flutter/material.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_frequency.dart';
import '../../../habits/domain/entities/habit_type.dart';
import '../../../habits/presentation/extensions/habit_color_extension.dart';
import '../../../habits/presentation/extensions/habit_icon_extension.dart';

/// Reusable Material 3 Habit Card widget for displaying habit summary details.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
  });

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

  String? _formatTargetValue(Habit habit) {
    switch (habit.habitType) {
      case HabitType.numeric:
        return 'Target: ${habit.targetCount}';
      case HabitType.timer:
        return 'Target: ${habit.targetCount} min${habit.targetCount == 1 ? '' : 's'}';
      case HabitType.boolean:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = habit.color.color;
    final targetText = _formatTargetValue(habit);
    final frequencyText = _formatFrequency(habit.frequency);
    final typeText = _formatHabitType(habit.habitType);

    return Semantics(
      label: 'Habit ${habit.title}, $frequencyText frequency, $typeText type${targetText != null ? ', $targetText' : ''}',
      button: true,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color accent & Icon avatar
                Container(
                  width: 48,
                  height: 48,
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
                // Content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Metadata chips row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _MetaBadge(
                            label: frequencyText,
                            backgroundColor: theme.colorScheme.secondaryContainer,
                            foregroundColor: theme.colorScheme.onSecondaryContainer,
                          ),
                          _MetaBadge(
                            label: typeText,
                            backgroundColor: theme.colorScheme.surfaceContainerHigh,
                            foregroundColor: theme.colorScheme.onSurfaceVariant,
                          ),
                          if (targetText != null)
                            _MetaBadge(
                              label: targetText,
                              backgroundColor: accentColor.withValues(alpha: 0.1),
                              foregroundColor: accentColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
