import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/dashboard/presentation/widgets/streak_badge.dart';

void main() {
  group('StreakBadge Widget Tests', () {
    testWidgets('renders streak count and flame icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakBadge(
              streakCount: 7,
              isProtected: false,
            ),
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit_rounded), findsNothing);
    });

    testWidgets('renders snowflake indicator when isProtected is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakBadge(
              streakCount: 5,
              isProtected: true,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit_rounded), findsOneWidget);
    });
  });
}
