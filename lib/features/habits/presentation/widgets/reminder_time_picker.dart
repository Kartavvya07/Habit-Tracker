import 'package:flutter/material.dart';

/// Interactive UI component for configuring habit reminders and selecting reminder times.
class ReminderTimePicker extends StatelessWidget {
  final bool isEnabled;
  final String? reminderTime;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<String> onTimeChanged;

  const ReminderTimePicker({
    super.key,
    required this.isEnabled,
    required this.reminderTime,
    required this.onEnabledChanged,
    required this.onTimeChanged,
  });

  TimeOfDay _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
    final parts = timeStr.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsedTime = _parseTimeOfDay(reminderTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Habit Reminder',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isEnabled,
                onChanged: (val) {
                  onEnabledChanged(val);
                  if (val && (reminderTime == null || reminderTime!.isEmpty)) {
                    onTimeChanged('08:00');
                  }
                },
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reminder Time',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: parsedTime,
                    );
                    if (picked != null) {
                      onTimeChanged(_formatTimeOfDay(picked));
                    }
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    parsedTime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
