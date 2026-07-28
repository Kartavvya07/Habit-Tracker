import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../habits/presentation/providers/habit_completion_provider.dart';
import '../../../settings/presentation/providers/vacation_mode_provider.dart';
import 'completion_ring.dart';

/// Header summary card displaying today's completion ring, stats, and status.
class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncStats = ref.watch(todayCompletionsProvider);
    final isVacationModeActive = ref.watch(vacationModeProvider);

    final stats = asyncStats.valueOrNull;
    final total = stats?.totalHabits ?? 0;
    final completed = stats?.completedHabits ?? 0;
    final percentage = stats?.completionPercentage ?? 0.0;
    final isFullyCompleted = stats?.isFullyCompleted ?? false;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isFullyCompleted
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isFullyCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Progress Ring
            CompletionRing(
              progress: percentage,
              size: 64,
              strokeWidth: 7,
              color: isFullyCompleted ? Colors.green : theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            // Metrics Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Today\'s Overview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (isVacationModeActive) ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Vacation Mode active',
                          child: Icon(
                            Icons.beach_access_rounded,
                            size: 16,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total == 0
                        ? 'No habits scheduled for today'
                        : '$completed of $total habits completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isFullyCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      '🎉 All habits completed today!',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
