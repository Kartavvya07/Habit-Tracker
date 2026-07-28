import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_duration.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/duration_picker.dart';

void main() {
  group('DurationPicker Widget Tests', () {
    testWidgets('renders initial duration and labels correctly', (tester) async {
      const initial = HabitDuration(5430); // 1 hr 30 min 30 sec
      HabitDuration? changed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DurationPicker(
              initialDuration: initial,
              onChanged: (d) => changed = d,
            ),
          ),
        ),
      );

      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('Minutes'), findsOneWidget);
      expect(find.text('Seconds'), findsOneWidget);
      expect(find.text('1 hr 30 min 30 sec'), findsOneWidget);
      expect(changed, isNull);
    });

    testWidgets('scrolls wheels and triggers onChanged callback', (tester) async {
      const initial = HabitDuration(0);
      HabitDuration? updated;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DurationPicker(
              initialDuration: initial,
              onChanged: (d) => updated = d,
            ),
          ),
        ),
      );

      // Drag minutes wheel up/down
      final minutesWheel = find.bySemanticsLabel('Minutes scroll wheel');
      expect(minutesWheel, findsOneWidget);

      await tester.drag(minutesWheel, const Offset(0, -36));
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.totalSeconds, greaterThan(0));
    });
  });
}
