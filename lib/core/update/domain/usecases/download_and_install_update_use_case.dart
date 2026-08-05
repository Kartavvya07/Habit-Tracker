import 'dart:io';

import '../../models/update_manifest.dart';
import '../repositories/update_repository.dart';

/// Use case handling APK download streaming, SHA-256 verification, and installer launch.
class DownloadAndInstallUpdateUseCase {
  final UpdateRepository repository;

  DownloadAndInstallUpdateUseCase({required this.repository});

  Future<File> execute(
    UpdateManifest manifest, {
    required void Function(double progress) onProgress,
  }) async {
    final apkFile = await repository.downloadApk(
      manifest.apkUrl,
      onProgress: onProgress,
    );

    if (manifest.sha256 != null && manifest.sha256!.isNotEmpty) {
      final isChecksumValid = await repository.verifyChecksum(
        apkFile,
        manifest.sha256!,
      );
      if (!isChecksumValid) {
        throw Exception('SHA-256 checksum verification failed for downloaded APK');
      }
    }

    await repository.installApk(apkFile);
    return apkFile;
  }
}
