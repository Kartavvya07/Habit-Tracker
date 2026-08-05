import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/update/data/datasources/update_local_data_source.dart';
import 'package:habit_tracker/core/update/data/datasources/update_remote_data_source.dart';
import 'package:habit_tracker/core/update/data/repositories/update_repository_impl.dart';
import 'package:habit_tracker/core/update/models/update_channel.dart';
import 'package:habit_tracker/core/update/models/update_manifest.dart';
import 'package:habit_tracker/core/update/services/apk_installer_service.dart';
import 'package:habit_tracker/core/update/services/checksum_service.dart';

class FakeRemoteDataSource implements UpdateRemoteDataSource {
  UpdateManifest manifestToReturn = const UpdateManifest(
    channel: 'development',
    latestBuild: 182,
    version: '0.4.0-dev.182',
    apkUrl: 'https://example.com/app.apk',
  );

  @override
  Future<UpdateManifest> fetchManifest(UpdateChannel channel) async => manifestToReturn;

  @override
  Future<File> downloadApk(String url, {required void Function(double progress) onProgress}) async {
    onProgress(0.5);
    onProgress(1.0);
    return File('/tmp/test.apk');
  }
}

class FakeLocalDataSource implements UpdateLocalDataSource {
  UpdateManifest? cached;
  UpdateChannel channel = UpdateChannel.development;

  @override
  Future<UpdateManifest?> getCachedManifest() async => cached;

  @override
  Future<void> cacheManifest(UpdateManifest manifest) async {
    cached = manifest;
  }

  @override
  Future<UpdateChannel> getSelectedChannel() async => channel;

  @override
  Future<void> setSelectedChannel(UpdateChannel channel) async {
    this.channel = channel;
  }
}

class FakeChecksumService implements ChecksumService {
  @override
  Future<String> calculateSha256(File file) async => 'mocked_sha256';

  @override
  Future<bool> verifySha256(File file, String expectedSha256) async => true;
}

class FakeApkInstallerService implements ApkInstallerService {
  @override
  Future<bool> installApk(File apkFile) async => true;
}

void main() {
  group('UpdateRepositoryImpl Tests', () {
    late FakeRemoteDataSource remoteDS;
    late FakeLocalDataSource localDS;
    late FakeChecksumService checksumService;
    late FakeApkInstallerService installerService;
    late UpdateRepositoryImpl repository;

    setUp(() {
      remoteDS = FakeRemoteDataSource();
      localDS = FakeLocalDataSource();
      checksumService = FakeChecksumService();
      installerService = FakeApkInstallerService();

      repository = UpdateRepositoryImpl(
        remoteDataSource: remoteDS,
        localDataSource: localDS,
        checksumService: checksumService,
        installerService: installerService,
      );
    });

    test('fetchRemoteManifest fetches from remote and caches result', () async {
      final manifest = await repository.fetchRemoteManifest(UpdateChannel.development);

      expect(manifest, remoteDS.manifestToReturn);
      expect(localDS.cached, remoteDS.manifestToReturn);
    });

    test('getSelectedChannel and setSelectedChannel update local store', () async {
      expect(await repository.getSelectedChannel(), UpdateChannel.development);

      await repository.setSelectedChannel(UpdateChannel.stable);
      expect(await repository.getSelectedChannel(), UpdateChannel.stable);
    });
  });
}
