import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/settings/presentation/widgets/battery_optimization_dialog.dart';

void main() {
  group('BatteryOptimizationDialog Widget Tests', () {
    testWidgets('renders guide title, steps, and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BatteryOptimizationDialog(),
          ),
        ),
      );

      expect(find.text('Battery Optimization Guide'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Disable Battery Optimization'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
    });
  });
}
