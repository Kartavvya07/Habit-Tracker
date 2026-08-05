import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/update/models/update_manifest.dart';

void main() {
  group('UpdateManifest JSON Parsing Tests', () {
    test('parses full json payload correctly', () {
      final json = {
        'channel': 'development',
        'latestBuild': 182,
        'version': '0.4.0-dev.182',
        'apkUrl': 'https://example.com/build-182.apk',
        'sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        'releaseNotes': [
          'Timer formatting',
          'Archive improvements',
          'Bottom sheet fixes',
        ],
        'publishedAt': '2026-08-05T12:00:00Z',
        'mandatory': false,
      };

      final manifest = UpdateManifest.fromJson(json);

      expect(manifest.channel, 'development');
      expect(manifest.latestBuild, 182);
      expect(manifest.version, '0.4.0-dev.182');
      expect(manifest.apkUrl, 'https://example.com/build-182.apk');
      expect(manifest.sha256, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855');
      expect(manifest.releaseNotes, [
        'Timer formatting',
        'Archive improvements',
        'Bottom sheet fixes',
      ]);
      expect(manifest.publishedAt, '2026-08-05T12:00:00Z');
      expect(manifest.mandatory, false);
      expect(manifest.extraFields, isEmpty);
    });

    test('forward compatibility: tolerates extra unknown fields without failing', () {
      final json = {
        'channel': 'development',
        'latestBuild': 185,
        'version': '0.4.0-dev.185',
        'apkUrl': 'https://example.com/app.apk',
        'futureFeatureFlag': true,
        'newMetadataField': {'key': 'value'},
      };

      final manifest = UpdateManifest.fromJson(json);

      expect(manifest.latestBuild, 185);
      expect(manifest.extraFields.containsKey('futureFeatureFlag'), isTrue);
      expect(manifest.extraFields['futureFeatureFlag'], isTrue);
    });

    test('defaults missing or null fields gracefully', () {
      final json = <String, dynamic>{};

      final manifest = UpdateManifest.fromJson(json);

      expect(manifest.channel, 'development');
      expect(manifest.latestBuild, 0);
      expect(manifest.version, '');
      expect(manifest.releaseNotes, isEmpty);
      expect(manifest.mandatory, false);
    });
  });
}
