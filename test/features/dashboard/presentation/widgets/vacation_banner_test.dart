import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/dashboard/presentation/widgets/vacation_banner.dart';

void main() {
  group('VacationBanner Widget Tests', () {
    testWidgets('renders banner content when isActive is true', (tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VacationBanner(
              isActive: true,
              onToggle: () => toggled = true,
            ),
          ),
        ),
      );

      expect(find.text('Vacation Mode Active'), findsOneWidget);
      expect(
        find.text('Streaks are frozen and protected from resetting.'),
        findsOneWidget,
      );
      expect(find.text('Resume'), findsOneWidget);

      await tester.tap(find.text('Resume'));
      expect(toggled, isTrue);
    });

    testWidgets('does not show content when isActive is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VacationBanner(
              isActive: false,
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.text('Vacation Mode Active'), findsNothing);
    });
  });
}
