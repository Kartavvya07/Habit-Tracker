import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/update_local_data_source.dart';
import '../data/datasources/update_remote_data_source.dart';
import '../data/repositories/update_repository_impl.dart';
import '../domain/repositories/update_repository.dart';
import '../domain/usecases/check_for_updates_use_case.dart';
import '../domain/usecases/download_and_install_update_use_case.dart';
import '../models/app_version_info.dart';
import '../models/update_channel.dart';
import '../models/update_manifest.dart';
import '../models/update_state.dart';
import '../services/apk_installer_service.dart';
import '../services/checksum_service.dart';
import '../services/package_info_service.dart';

/// Provider for [PackageInfoService].
final packageInfoServiceProvider = Provider<PackageInfoService>((ref) {
  return const DefaultPackageInfoService();
});

/// Provider for [ChecksumService].
final checksumServiceProvider = Provider<ChecksumService>((ref) {
  return const DefaultChecksumService();
});

/// Provider for [ApkInstallerService].
final apkInstallerServiceProvider = Provider<ApkInstallerService>((ref) {
  return const DefaultApkInstallerService();
});

/// Provider for [UpdateRemoteDataSource].
final updateRemoteDataSourceProvider = Provider<UpdateRemoteDataSource>((ref) {
  return HttpUpdateRemoteDataSource();
});

/// Provider for [UpdateLocalDataSource].
final updateLocalDataSourceProvider = Provider<UpdateLocalDataSource>((ref) {
  return SharedPreferencesUpdateLocalDataSource();
});

/// Provider for [UpdateRepository].
final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  return UpdateRepositoryImpl(
    remoteDataSource: ref.watch(updateRemoteDataSourceProvider),
    localDataSource: ref.watch(updateLocalDataSourceProvider),
    checksumService: ref.watch(checksumServiceProvider),
    installerService: ref.watch(apkInstallerServiceProvider),
  );
});

/// Provider for [CheckForUpdatesUseCase].
final checkForUpdatesUseCaseProvider = Provider<CheckForUpdatesUseCase>((ref) {
  return CheckForUpdatesUseCase(
    repository: ref.watch(updateRepositoryProvider),
    packageInfoService: ref.watch(packageInfoServiceProvider),
  );
});

/// Provider for [DownloadAndInstallUpdateUseCase].
final downloadAndInstallUpdateUseCaseProvider =
    Provider<DownloadAndInstallUpdateUseCase>((ref) {
  return DownloadAndInstallUpdateUseCase(
    repository: ref.watch(updateRepositoryProvider),
  );
});

/// StateNotifier for managing update channel selection.
class UpdateChannelNotifier extends StateNotifier<UpdateChannel> {
  final UpdateRepository repository;

  UpdateChannelNotifier(this.repository) : super(UpdateChannel.development) {
    _init();
  }

  Future<void> _init() async {
    state = await repository.getSelectedChannel();
  }

  Future<void> setChannel(UpdateChannel channel) async {
    state = channel;
    await repository.setSelectedChannel(channel);
  }
}

/// Provider for selected update channel.
final updateChannelProvider =
    StateNotifierProvider<UpdateChannelNotifier, UpdateChannel>((ref) {
  final repository = ref.watch(updateRepositoryProvider);
  return UpdateChannelNotifier(repository);
});

/// StateNotifier managing update execution lifecycle.
class UpdateNotifier extends StateNotifier<UpdateState> {
  final CheckForUpdatesUseCase _checkForUpdatesUseCase;
  final DownloadAndInstallUpdateUseCase _downloadAndInstallUpdateUseCase;
  final UpdateRepository _repository;
  final PackageInfoService _packageInfoService;

  UpdateNotifier({
    required CheckForUpdatesUseCase checkForUpdatesUseCase,
    required DownloadAndInstallUpdateUseCase downloadAndInstallUpdateUseCase,
    required UpdateRepository repository,
    required PackageInfoService packageInfoService,
  })  : _checkForUpdatesUseCase = checkForUpdatesUseCase,
        _downloadAndInstallUpdateUseCase = downloadAndInstallUpdateUseCase,
        _repository = repository,
        _packageInfoService = packageInfoService,
        super(const UpdateStateIdle());

  Future<AppVersionInfo> getAppVersionInfo() async {
    return _packageInfoService.getAppVersionInfo();
  }

  Future<void> checkForUpdates({
    bool isManual = false,
    UpdateChannel? channel,
  }) async {
    state = UpdateStateChecking(isManual: isManual);

    try {
      final manifest = await _checkForUpdatesUseCase.execute(
        channel: channel,
        isManual: isManual,
      );

      if (manifest != null) {
        state = UpdateStateAvailable(manifest);
      } else {
        state = const UpdateStateIdle();
      }
    } catch (e) {
      if (isManual) {
        state = UpdateStateFailed(e.toString().replaceAll('Exception: ', ''));
      } else {
        state = const UpdateStateIdle();
      }
    }
  }

  Future<void> downloadAndInstall(UpdateManifest manifest) async {
    state = UpdateStateDownloading(manifest, 0.0);

    try {
      final apkFile = await _downloadAndInstallUpdateUseCase.execute(
        manifest,
        onProgress: (progress) {
          if (mounted) {
            state = UpdateStateDownloading(manifest, progress);
          }
        },
      );

      if (mounted) {
        state = UpdateStateInstalling(manifest);
      }

      final success = await _repository.installApk(apkFile);
      if (mounted) {
        if (success) {
          state = UpdateStateCompleted(apkFile.path);
        } else {
          state = const UpdateStateFailed('Installation failed to launch');
        }
      }
    } catch (e) {
      if (mounted) {
        state = UpdateStateFailed(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void dismissUpdate() {
    state = const UpdateStateIdle();
  }
}

/// Main Provider for [UpdateNotifier].
final updateProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier(
    checkForUpdatesUseCase: ref.watch(checkForUpdatesUseCaseProvider),
    downloadAndInstallUpdateUseCase:
        ref.watch(downloadAndInstallUpdateUseCaseProvider),
    repository: ref.watch(updateRepositoryProvider),
    packageInfoService: ref.watch(packageInfoServiceProvider),
  );
});
