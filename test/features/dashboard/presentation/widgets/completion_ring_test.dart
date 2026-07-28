import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/dashboard/presentation/widgets/completion_ring.dart';

void main() {
  group('CompletionRing Widget Tests', () {
    testWidgets('renders completion percentage text and animates progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompletionRing(
              progress: 0.75,
              size: 64,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('renders custom child when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompletionRing(
              progress: 1.0,
              size: 64,
              child: Icon(Icons.check),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
