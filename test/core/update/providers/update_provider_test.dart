import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/update/domain/repositories/update_repository.dart';
import 'package:habit_tracker/core/update/models/app_version_info.dart';
import 'package:habit_tracker/core/update/models/update_channel.dart';
import 'package:habit_tracker/core/update/models/update_manifest.dart';
import 'package:habit_tracker/core/update/models/update_state.dart';
import 'package:habit_tracker/core/update/providers/update_providers.dart';
import 'package:habit_tracker/core/update/services/package_info_service.dart';

class MockPackageInfoService implements PackageInfoService {
  @override
  Future<AppVersionInfo> getAppVersionInfo() async =>
      const AppVersionInfo(version: '0.4.0-dev.179', buildNumber: 179);
}

class FakeUpdateRepository implements UpdateRepository {
  UpdateManifest? manifest;

  @override
  Future<UpdateManifest?> fetchRemoteManifest(UpdateChannel channel) async => manifest;

  @override
  Future<UpdateManifest?> getCachedManifest() async => manifest;

  @override
  Future<void> cacheManifest(UpdateManifest manifest) async {}

  @override
  Future<File> downloadApk(String url, {required void Function(double progress) onProgress}) async {
    onProgress(0.5);
    onProgress(1.0);
    return File('/tmp/fake.apk');
  }

  @override
  Future<bool> verifyChecksum(File apkFile, String expectedSha256) async => true;

  @override
  Future<bool> installApk(File apkFile) async => true;

  @override
  Future<UpdateChannel> getSelectedChannel() async => UpdateChannel.development;

  @override
  Future<void> setSelectedChannel(UpdateChannel channel) async {}
}

void main() {
  group('UpdateNotifier Provider Tests', () {
    late FakeUpdateRepository fakeRepo;
    late MockPackageInfoService fakePackageInfo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeUpdateRepository();
      fakePackageInfo = MockPackageInfoService();

      container = ProviderContainer(
        overrides: [
          updateRepositoryProvider.overrideWithValue(fakeRepo),
          packageInfoServiceProvider.overrideWithValue(fakePackageInfo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is UpdateStateIdle', () {
      final state = container.read(updateProvider);
      expect(state, const UpdateStateIdle());
    });

    test('checkForUpdates transitions to UpdateStateAvailable when update exists', () async {
      fakeRepo.manifest = const UpdateManifest(
        channel: 'development',
        latestBuild: 182,
        version: '0.4.0-dev.182',
        apkUrl: 'https://example.com/app.apk',
      );

      final notifier = container.read(updateProvider.notifier);
      await notifier.checkForUpdates(isManual: true);

      final state = container.read(updateProvider);
      expect(state, isA<UpdateStateAvailable>());
      expect((state as UpdateStateAvailable).manifest.latestBuild, 182);
    });

    test('checkForUpdates transitions to UpdateStateIdle when no update exists', () async {
      fakeRepo.manifest = const UpdateManifest(
        channel: 'development',
        latestBuild: 179,
        version: '0.4.0-dev.179',
        apkUrl: 'https://example.com/app.apk',
      );

      final notifier = container.read(updateProvider.notifier);
      await notifier.checkForUpdates(isManual: true);

      final state = container.read(updateProvider);
      expect(state, const UpdateStateIdle());
    });

    test('downloadAndInstall transitions through downloading to completed', () async {
      const manifest = UpdateManifest(
        channel: 'development',
        latestBuild: 182,
        version: '0.4.0-dev.182',
        apkUrl: 'https://example.com/app.apk',
      );

      final notifier = container.read(updateProvider.notifier);
      await notifier.downloadAndInstall(manifest);

      final state = container.read(updateProvider);
      expect(state, isA<UpdateStateCompleted>());
    });
  });
}
