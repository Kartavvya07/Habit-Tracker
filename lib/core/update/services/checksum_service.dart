import 'dart:io';
import 'package:crypto/crypto.dart';

/// Service interface for SHA-256 hash calculation and verification.
abstract class ChecksumService {
  Future<String> calculateSha256(File file);
  Future<bool> verifySha256(File file, String expectedSha256);
}

/// Default implementation using crypto library sha256 algorithm.
class DefaultChecksumService implements ChecksumService {
  const DefaultChecksumService();

  @override
  Future<String> calculateSha256(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<bool> verifySha256(File file, String expectedSha256) async {
    final expected = expectedSha256.trim();
    if (expected.isEmpty) return true;
    final actual = await calculateSha256(file);
    return actual.toLowerCase() == expected.toLowerCase();
  }
}
