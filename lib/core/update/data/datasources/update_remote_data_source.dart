import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../models/update_channel.dart';
import '../../models/update_manifest.dart';

/// Abstract remote data source for querying update manifests and downloading APKs.
abstract class UpdateRemoteDataSource {
  Future<UpdateManifest> fetchManifest(UpdateChannel channel);
  Future<File> downloadApk(
    String url, {
    required void Function(double progress) onProgress,
  });
}

/// HTTP implementation of [UpdateRemoteDataSource].
class HttpUpdateRemoteDataSource implements UpdateRemoteDataSource {
  final http.Client _client;
  final String? baseManifestUrl;

  HttpUpdateRemoteDataSource({
    http.Client? client,
    this.baseManifestUrl,
  }) : _client = client ?? http.Client();

  @override
  Future<UpdateManifest> fetchManifest(UpdateChannel channel) async {
    final urlString = baseManifestUrl ??
        'https://raw.githubusercontent.com/kartavvya07/Habit-Tracker/main/updates/${channel.id}.json';
    final uri = Uri.parse(urlString);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap =
            jsonDecode(response.body) as Map<String, dynamic>;
        return UpdateManifest.fromJson(jsonMap);
      } else {
        throw HttpException('Failed to fetch update manifest: HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      throw TimeoutException('Update check timed out');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<File> downloadApk(
    String url, {
    required void Function(double progress) onProgress,
  }) async {
    final uri = Uri.parse(url);
    final request = http.Request('GET', uri);
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw HttpException('Failed to download APK: HTTP ${response.statusCode}');
    }

    final contentLength = response.contentLength ?? 0;
    final tempDir = await getTemporaryDirectory();
    final fileName = 'update_${DateTime.now().millisecondsSinceEpoch}.apk';
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    final sink = file.openWrite();

    int downloadedBytes = 0;

    await for (final chunk in response.stream) {
      downloadedBytes += chunk.length;
      sink.add(chunk);

      if (contentLength > 0) {
        final progress = (downloadedBytes / contentLength).clamp(0.0, 1.0);
        onProgress(progress);
      } else {
        onProgress(0.5);
      }
    }

    await sink.flush();
    await sink.close();

    onProgress(1.0);
    return file;
  }
}
