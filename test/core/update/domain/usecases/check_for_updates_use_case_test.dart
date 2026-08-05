import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/update/domain/repositories/update_repository.dart';
import 'package:habit_tracker/core/update/domain/usecases/check_for_updates_use_case.dart';
import 'package:habit_tracker/core/update/models/app_version_info.dart';
import 'package:habit_tracker/core/update/models/update_channel.dart';
import 'package:habit_tracker/core/update/models/update_manifest.dart';
import 'package:habit_tracker/core/update/services/package_info_service.dart';

class MockPackageInfoService implements PackageInfoService {
  final AppVersionInfo info;
  MockPackageInfoService(this.info);

  @override
  Future<AppVersionInfo> getAppVersionInfo() async => info;
}

class FakeUpdateRepository implements UpdateRepository {
  UpdateManifest? remoteManifest;
  UpdateManifest? cachedManifest;
  UpdateChannel selectedChannel = UpdateChannel.development;

  @override
  Future<UpdateManifest?> fetchRemoteManifest(UpdateChannel channel) async {
    if (remoteManifest == null) {
      throw Exception('Network error');
    }
    return remoteManifest;
  }

  @override
  Future<UpdateManifest?> getCachedManifest() async => cachedManifest;

  @override
  Future<void> cacheManifest(UpdateManifest manifest) async {
    cachedManifest = manifest;
  }

  @override
  Future<File> downloadApk(String url, {required void Function(double progress) onProgress}) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyChecksum(File apkFile, String expectedSha256) async => true;

  @override
  Future<bool> installApk(File apkFile) async => true;

  @override
  Future<UpdateChannel> getSelectedChannel() async => selectedChannel;

  @override
  Future<void> setSelectedChannel(UpdateChannel channel) async {
    selectedChannel = channel;
  }
}

void main() {
  group('CheckForUpdatesUseCase Tests', () {
    late FakeUpdateRepository repository;
    late MockPackageInfoService packageInfoService;
    late CheckForUpdatesUseCase useCase;

    setUp(() {
      repository = FakeUpdateRepository();
      packageInfoService = MockPackageInfoService(
        const AppVersionInfo(version: '0.4.0-dev.179', buildNumber: 179),
      );
      useCase = CheckForUpdatesUseCase(
        repository: repository,
        packageInfoService: packageInfoService,
      );
    });

    test('returns manifest when remote build number is greater than current', () async {
      repository.remoteManifest = const UpdateManifest(
        channel: 'development',
        latestBuild: 182,
        version: '0.4.0-dev.182',
        apkUrl: 'https://example.com/app.apk',
      );

      final result = await useCase.execute();

      expect(result, isNotNull);
      expect(result!.latestBuild, 182);
    });

    test('returns null when remote build number is equal or lower', () async {
      repository.remoteManifest = const UpdateManifest(
        channel: 'development',
        latestBuild: 179,
        version: '0.4.0-dev.179',
        apkUrl: 'https://example.com/app.apk',
      );

      final result = await useCase.execute();

      expect(result, isNull);
    });

    test('falls back to cached manifest when network request fails', () async {
      repository.remoteManifest = null;
      repository.cachedManifest = const UpdateManifest(
        channel: 'development',
        latestBuild: 185,
        version: '0.4.0-dev.185',
        apkUrl: 'https://example.com/cached.apk',
      );

      final result = await useCase.execute();

      expect(result, isNotNull);
      expect(result!.latestBuild, 185);
    });
  });
}
