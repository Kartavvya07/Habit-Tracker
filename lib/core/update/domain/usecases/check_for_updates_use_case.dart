import '../../models/app_version_info.dart';
import '../../models/update_channel.dart';
import '../../models/update_manifest.dart';
import '../../services/package_info_service.dart';
import '../repositories/update_repository.dart';

/// Use case responsible for version comparison and determining update availability.
class CheckForUpdatesUseCase {
  final UpdateRepository repository;
  final PackageInfoService packageInfoService;

  CheckForUpdatesUseCase({
    required this.repository,
    required this.packageInfoService,
  });

  Future<UpdateManifest?> execute({
    UpdateChannel? channel,
    bool isManual = false,
  }) async {
    final selectedChannel = channel ?? await repository.getSelectedChannel();
    final appInfo = await packageInfoService.getAppVersionInfo();

    UpdateManifest? manifest;
    try {
      manifest = await repository.fetchRemoteManifest(selectedChannel);
    } catch (_) {
      // On failure, fall back to cached manifest for offline checking
      manifest = await repository.getCachedManifest();
      if (manifest != null && manifest.channel != selectedChannel.id) {
        manifest = null;
      }
    }

    if (manifest == null) return null;

    if (isNewerVersion(appInfo, manifest)) {
      return manifest;
    }

    return null;
  }

  bool isNewerVersion(AppVersionInfo currentInfo, UpdateManifest manifest) {
    if (manifest.latestBuild > currentInfo.buildNumber) {
      return true;
    }
    if (manifest.latestBuild == currentInfo.buildNumber) {
      if (manifest.version.isNotEmpty && manifest.version != currentInfo.version) {
        return manifest.version.compareTo(currentInfo.version) > 0;
      }
    }
    return false;
  }
}
