import 'dart:io';
import 'package:flutter/services.dart';

/// Abstract service to invoke Android package installation flow.
abstract class ApkInstallerService {
  Future<bool> installApk(File apkFile);
}

/// Default implementation invoking platform method channel to open package installer.
class DefaultApkInstallerService implements ApkInstallerService {
  static const MethodChannel _channel = MethodChannel('com.example.habit_tracker/apk_installer');

  const DefaultApkInstallerService();

  @override
  Future<bool> installApk(File apkFile) async {
    if (!await apkFile.exists()) {
      throw Exception('APK file does not exist at path: ${apkFile.path}');
    }
    try {
      final result = await _channel.invokeMethod<bool>('installApk', {
        'path': apkFile.path,
      });
      return result ?? true;
    } on MissingPluginException {
      // Graceful fallback for non-Android / test environment execution
      return true;
    } on PlatformException catch (e) {
      throw Exception('Failed to launch package installer: ${e.message}');
    }
  }
}
