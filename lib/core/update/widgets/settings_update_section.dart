import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_version_info.dart';
import '../models/update_channel.dart';
import '../models/update_state.dart';
import '../providers/update_providers.dart';

/// Reusable UI section for Settings screen managing Update configurations & manual checks.
class SettingsUpdateSection extends ConsumerStatefulWidget {
  const SettingsUpdateSection({super.key});

  @override
  ConsumerState<SettingsUpdateSection> createState() => _SettingsUpdateSectionState();
}

class _SettingsUpdateSectionState extends ConsumerState<SettingsUpdateSection> {
  AppVersionInfo? _versionInfo;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final info = await ref.read(packageInfoServiceProvider).getAppVersionInfo();
    if (mounted) {
      setState(() {
        _versionInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChannel = ref.watch(updateChannelProvider);
    final updateState = ref.watch(updateProvider);
    final theme = Theme.of(context);

    final isChecking = updateState is UpdateStateChecking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Updates',
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
                leading: const Icon(Icons.info_outline),
                title: const Text('Current Version'),
                subtitle: Text(_versionInfo?.version ?? '0.4.0-dev.179'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.build_outlined),
                title: const Text('Current Build'),
                subtitle: Text(_versionInfo?.buildNumber.toString() ?? '179'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.alt_route),
                title: const Text('Update Channel'),
                subtitle: Text(selectedChannel.displayName),
                trailing: DropdownButton<UpdateChannel>(
                  value: selectedChannel,
                  underline: const SizedBox.shrink(),
                  items: UpdateChannel.values.map((channel) {
                    return DropdownMenuItem<UpdateChannel>(
                      value: channel,
                      child: Text(channel.displayName),
                    );
                  }).toList(),
                  onChanged: (channel) {
                    if (channel != null) {
                      ref.read(updateChannelProvider.notifier).setChannel(channel);
                    }
                  },
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Check for Updates'),
                subtitle: isChecking
                    ? const Text('Checking for updates...')
                    : const Text('Manually verify if a newer build is available'),
                trailing: isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: isChecking
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await ref
                            .read(updateProvider.notifier)
                            .checkForUpdates(isManual: true, channel: selectedChannel);
                        if (!mounted) return;
                        final newState = ref.read(updateProvider);
                        if (newState is UpdateStateIdle) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('You are on the latest version!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
