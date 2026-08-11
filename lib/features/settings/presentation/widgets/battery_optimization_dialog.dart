import 'package:flutter/material.dart';

/// Material 3 dialog guiding users through OEM battery optimization exemptions
/// (Xiaomi MIUI, Samsung OneUI, Huawei EMUI, etc.) for reliable reminder delivery.
class BatteryOptimizationDialog extends StatelessWidget {
  const BatteryOptimizationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.battery_alert,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Battery Optimization Guide',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'To ensure habit reminders trigger reliably at scheduled times, please grant background activity permissions:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildStepTile(
              context,
              number: '1',
              title: 'Disable Battery Optimization',
              description:
                  'Set app battery usage to "Unrestricted" or "No restrictions".',
            ),
            const SizedBox(height: 12),
            _buildStepTile(
              context,
              number: '2',
              title: 'Enable Auto-Start (OEM Devices)',
              description:
                  'On MIUI, OneUI, or ColorOS, enable "Auto-start" or "Background execution".',
            ),
            const SizedBox(height: 12),
            _buildStepTile(
              context,
              number: '3',
              title: 'Lock in Recent Apps',
              description:
                  'Lock Habit Tracker in your recent app switcher to prevent system task killers.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.settings),
          label: const Text('Open Settings'),
        ),
      ],
    );
  }

  Widget _buildStepTile(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            number,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
