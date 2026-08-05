import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/update/widgets/settings_update_section.dart';
import '../providers/vacation_mode_provider.dart';

/// App Settings screen incorporating Vacation Mode & Updates management.
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
                  const SettingsUpdateSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
