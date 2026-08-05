import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/update/widgets/settings_update_section.dart';

void main() {
  group('SettingsUpdateSection Widget Tests', () {
    testWidgets('renders updates section with version, build, channel and check button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              child: SettingsUpdateSection(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Updates'), findsOneWidget);
      expect(find.text('Current Version'), findsOneWidget);
      expect(find.text('Current Build'), findsOneWidget);
      expect(find.text('Update Channel'), findsOneWidget);
      expect(find.text('Development'), findsWidgets);
      expect(find.text('Check for Updates'), findsOneWidget);
    });
  });
}
