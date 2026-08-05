import 'dart:io';

import '../../domain/repositories/update_repository.dart';
import '../../models/update_channel.dart';
import '../../models/update_manifest.dart';
import '../../services/apk_installer_service.dart';
import '../../services/checksum_service.dart';
import '../datasources/update_local_data_source.dart';
import '../datasources/update_remote_data_source.dart';

/// Implementation of [UpdateRepository] enforcing Clean Architecture boundaries.
class UpdateRepositoryImpl implements UpdateRepository {
  final UpdateRemoteDataSource remoteDataSource;
  final UpdateLocalDataSource localDataSource;
  final ChecksumService checksumService;
  final ApkInstallerService installerService;

  UpdateRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.checksumService,
    required this.installerService,
  });

  @override
  Future<UpdateManifest?> fetchRemoteManifest(UpdateChannel channel) async {
    final manifest = await remoteDataSource.fetchManifest(channel);
    await cacheManifest(manifest);
    return manifest;
  }

  @override
  Future<UpdateManifest?> getCachedManifest() async {
    return localDataSource.getCachedManifest();
  }

  @override
  Future<void> cacheManifest(UpdateManifest manifest) async {
    await localDataSource.cacheManifest(manifest);
  }

  @override
  Future<File> downloadApk(
    String url, {
    required void Function(double progress) onProgress,
  }) async {
    return remoteDataSource.downloadApk(url, onProgress: onProgress);
  }

  @override
  Future<bool> verifyChecksum(File apkFile, String expectedSha256) async {
    return checksumService.verifySha256(apkFile, expectedSha256);
  }

  @override
  Future<bool> installApk(File apkFile) async {
    return installerService.installApk(apkFile);
  }

  @override
  Future<UpdateChannel> getSelectedChannel() async {
    return localDataSource.getSelectedChannel();
  }

  @override
  Future<void> setSelectedChannel(UpdateChannel channel) async {
    await localDataSource.setSelectedChannel(channel);
  }
}
