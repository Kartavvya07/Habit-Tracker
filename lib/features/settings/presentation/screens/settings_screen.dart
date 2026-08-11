import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_provider.dart';
import '../../../../core/update/widgets/settings_update_section.dart';
import '../providers/vacation_mode_provider.dart';
import '../widgets/battery_optimization_dialog.dart';

/// App Settings screen incorporating Vacation Mode, Notifications & Updates management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVacationModeActive = ref.watch(vacationModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Preferences',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SwitchListTile(
                      secondary: Icon(
                        isVacationModeActive
                            ? Icons.beach_access_rounded
                            : Icons.beach_access_outlined,
                        color: isVacationModeActive ? theme.colorScheme.tertiary : null,
                      ),
                      title: const Text('Vacation Mode'),
                      subtitle: const Text('Pause streaks and notifications while away'),
                      value: isVacationModeActive,
                      onChanged: (value) {
                        ref.read(vacationModeProvider.notifier).setVacationMode(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Notifications & Reminders',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.notifications_active_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Notification Permissions'),
                          subtitle: const Text('Request system notification permissions'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final notificationService =
                                ref.read(notificationServiceProvider);
                            final granted =
                                await notificationService.requestPermissions();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    granted
                                        ? 'Notification permissions granted'
                                        : 'Notification permissions denied',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.battery_saver_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Battery Optimization Guide'),
                          subtitle: const Text(
                            'Exempt app from OEM task killers for reliable alarms',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (_) => const BatteryOptimizationDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SettingsUpdateSection(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'About',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: const Text('Habit Tracker'),
                      subtitle: const Text('Version 0.5.0-beta'),
                      trailing: Text(
                        'Clean Architecture',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
