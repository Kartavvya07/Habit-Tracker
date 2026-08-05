// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main(List<String> args) async {
  final isDryRun = args.contains('--dry-run');
  final noBump = args.contains('--no-bump');

  print('==================================================');
  print('  Habit Tracker - Development Update Publisher');
  print('==================================================');

  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('Error: pubspec.yaml not found in current working directory.');
    exit(1);
  }

  final pubspecContent = await pubspecFile.readAsString();
  final versionRegex = RegExp(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    print('Error: Could not parse version in pubspec.yaml');
    exit(1);
  }

  final baseVersion = match.group(1)!;
  final currentBuild = int.parse(match.group(2)!);
  final newBuild = noBump ? currentBuild : currentBuild + 1;
  final newVersionString = '$baseVersion-dev.$newBuild';

  print('Current version: $baseVersion+$currentBuild');
  print('Target version:  $baseVersion+$newBuild ($newVersionString)');

  if (!noBump && !isDryRun) {
    final updatedPubspec = pubspecContent.replaceFirst(
      versionRegex,
      'version: $baseVersion+$newBuild',
    );
    await pubspecFile.writeAsString(updatedPubspec);
    print('✔ Updated pubspec.yaml build number to $newBuild');
  }

  final apkFile = File('build/app/outputs/flutter-apk/app-release.apk');

  if (!isDryRun) {
    print('\n[1/3] Building Flutter release APK...');
    final buildResult = await Process.run(
      'flutter',
      ['build', 'apk', '--release'],
      runInShell: true,
    );

    if (buildResult.exitCode != 0) {
      print('Error building APK:\n${buildResult.stderr}');
      exit(1);
    }
    print('✔ APK built successfully.');
  } else {
    print('\n[1/3] Skipping Flutter build (dry-run).');
  }

  String sha256Hex;
  if (await apkFile.exists()) {
    print('\n[2/3] Calculating SHA-256 checksum...');
    final bytes = await apkFile.readAsBytes();
    sha256Hex = sha256.convert(bytes).toString();
    print('✔ SHA-256: $sha256Hex');
  } else {
    sha256Hex = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
    print('\n[2/3] APK file not found at ${apkFile.path}. Using placeholder checksum for dry-run.');
  }

  print('\n[3/3] Generating update manifests...');
  final manifestData = {
    'channel': 'development',
    'latestBuild': newBuild,
    'version': newVersionString,
    'apkUrl': 'https://github.com/kartavvya07/Habit-Tracker/releases/download/dev-build-$newBuild/app-release.apk',
    'sha256': sha256Hex,
    'releaseNotes': [
      'Development build $newBuild ($newVersionString)',
      'Automated in-app update channel verification',
      'Performance and stability improvements'
    ],
    'publishedAt': DateTime.now().toUtc().toIso8601String(),
    'mandatory': false,
  };

  const encoder = JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(manifestData);

  if (!isDryRun) {
    final updatesDir = Directory('updates');
    if (!await updatesDir.exists()) {
      await updatesDir.create(recursive: true);
    }

    final latestDevFile = File('updates/latest-dev.json');
    final devFile = File('updates/development.json');

    await latestDevFile.writeAsString('$jsonString\n');
    await devFile.writeAsString('$jsonString\n');

    print('✔ Updated updates/latest-dev.json');
    print('✔ Updated updates/development.json');
  } else {
    print('Manifest payload:\n$jsonString');
  }

  print('\n==================================================');
  print('  Build & Manifest Generation Complete!');
  print('==================================================');
  print('Build Number: $newBuild');
  print('Version:      $newVersionString');
  print('Manifest URL: https://raw.githubusercontent.com/kartavvya07/Habit-Tracker/main/updates/latest-dev.json');
  print('APK Release:  https://github.com/kartavvya07/Habit-Tracker/releases/download/dev-build-$newBuild/app-release.apk');
}
