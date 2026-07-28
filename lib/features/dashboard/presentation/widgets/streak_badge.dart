import 'package:flutter/material.dart';

/// Reusable badge widget displaying active habit streak count with flame icon and protected status.
class StreakBadge extends StatelessWidget {
  final int streakCount;
  final bool isProtected;

  const StreakBadge({
    super.key,
    required this.streakCount,
    this.isProtected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStreak = streakCount > 0;

    final flameColor = hasStreak
        ? const Color(0xFFFF6D00) // Vibrant fire orange
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    final backgroundColor = hasStreak
        ? const Color(0xFFFF6D00).withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5);

    return Semantics(
      label: 'Current streak $streakCount days${isProtected ? ', protected' : ''}',
      child: Tooltip(
        message: '$streakCount day streak${isProtected ? ' (Protected)' : ''}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: isProtected
                ? Border.all(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 18,
                color: flameColor,
              ),
              const SizedBox(width: 4),
              Text(
                '$streakCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasStreak
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isProtected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.ac_unit_rounded,
                  size: 13,
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
