import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/update_state.dart';
import '../providers/update_providers.dart';
import '../widgets/update_dialog.dart';

/// App lifecycle wrapper that performs a single non-blocking update check on launch
/// and displays [UpdateDialog] when a new build is detected.
class UpdateListener extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateListener({super.key, required this.child});

  @override
  ConsumerState<UpdateListener> createState() => _UpdateListenerState();
}

class _UpdateListenerState extends ConsumerState<UpdateListener> {
  bool _hasCheckedOnLaunch = false;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnLaunch();
    });
  }

  void _checkOnLaunch() {
    if (!_hasCheckedOnLaunch) {
      _hasCheckedOnLaunch = true;
      unawaited(ref.read(updateProvider.notifier).checkForUpdates(isManual: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UpdateState>(updateProvider, (previous, next) async {
      if (next is UpdateStateAvailable && !_isDialogShowing) {
        _isDialogShowing = true;
        final packageService = ref.read(packageInfoServiceProvider);
        final info = await packageService.getAppVersionInfo();
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: !next.manifest.mandatory,
          builder: (dialogContext) => UpdateDialog(
            manifest: next.manifest,
            currentVersion: info.version,
          ),
        );
        _isDialogShowing = false;
      }
    });

    return widget.child;
  }
}
