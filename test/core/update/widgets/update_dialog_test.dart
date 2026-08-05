import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/update/models/update_manifest.dart';
import 'package:habit_tracker/core/update/widgets/update_dialog.dart';

void main() {
  group('UpdateDialog Widget Tests', () {
    const manifest = UpdateManifest(
      channel: 'development',
      latestBuild: 182,
      version: '0.4.0-dev.182',
      apkUrl: 'https://example.com/app.apk',
      releaseNotes: [
        'Timer formatting',
        'Archive improvements',
        'Bottom sheet fixes',
      ],
    );

    testWidgets('renders title, current version, latest version, and release notes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProviderScope(
            child: UpdateDialog(
              manifest: manifest,
              currentVersion: '0.4.0-dev.179',
            ),
          ),
        ),
      );

      expect(find.text('Development Update Available'), findsOneWidget);
      expect(find.text('0.4.0-dev.179'), findsOneWidget);
      expect(find.text('0.4.0-dev.182'), findsOneWidget);
      expect(find.text('What\'s New'), findsOneWidget);
      expect(find.text('Timer formatting'), findsOneWidget);
      expect(find.text('Archive improvements'), findsOneWidget);
      expect(find.text('Bottom sheet fixes'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });
  });
}
