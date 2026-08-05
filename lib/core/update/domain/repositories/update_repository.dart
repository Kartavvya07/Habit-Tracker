import 'dart:io';

import '../../models/update_channel.dart';
import '../../models/update_manifest.dart';

/// Clean Architecture Domain repository interface for software updates.
abstract class UpdateRepository {
  /// Fetches the latest update manifest for the specified [channel].
  Future<UpdateManifest?> fetchRemoteManifest(UpdateChannel channel);

  /// Retrieves the locally cached manifest, if present.
  Future<UpdateManifest?> getCachedManifest();

  /// Persists [manifest] to local cache.
  Future<void> cacheManifest(UpdateManifest manifest);

  /// Downloads APK from [url] to local storage, invoking [onProgress] with values from 0.0 to 1.0.
  Future<File> downloadApk(
    String url, {
    required void Function(double progress) onProgress,
  });

  /// Verifies SHA-256 checksum of [apkFile] matches [expectedSha256].
  Future<bool> verifyChecksum(File apkFile, String expectedSha256);

  /// Launches the Android package installer for [apkFile].
  Future<bool> installApk(File apkFile);

  /// Retrieves user's currently selected update channel preference.
  Future<UpdateChannel> getSelectedChannel();

  /// Persists user's update channel preference.
  Future<void> setSelectedChannel(UpdateChannel channel);
}
