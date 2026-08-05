import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/update/services/checksum_service.dart';

void main() {
  group('ChecksumService Tests', () {
    late Directory tempDir;
    late File testFile;
    late DefaultChecksumService service;
    const testContent = 'Habit Tracker Update Test File Data';
    late String expectedHash;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('checksum_test_');
      testFile = File('${tempDir.path}/test_apk.bin');
      await testFile.writeAsString(testContent);

      expectedHash = sha256.convert(await testFile.readAsBytes()).toString();
      service = const DefaultChecksumService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('calculates correct SHA-256 digest', () async {
      final actualHash = await service.calculateSha256(testFile);
      expect(actualHash, expectedHash);
    });

    test('returns true when checksum matches (case insensitive)', () async {
      final isValidUpper = await service.verifySha256(testFile, expectedHash.toUpperCase());
      final isValidLower = await service.verifySha256(testFile, expectedHash.toLowerCase());

      expect(isValidUpper, isTrue);
      expect(isValidLower, isTrue);
    });

    test('returns false when checksum does not match', () async {
      final isValid = await service.verifySha256(testFile, 'invalid_sha256_hash');
      expect(isValid, isFalse);
    });

    test('returns true when expected checksum is empty', () async {
      final isValid = await service.verifySha256(testFile, '');
      expect(isValid, isTrue);
    });
  });
}
