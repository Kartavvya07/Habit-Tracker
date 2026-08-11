import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/reminder_time_picker.dart';

void main() {
  group('ReminderTimePicker Widget Tests', () {
    testWidgets('renders toggle switch and title correctly', (tester) async {
      bool isEnabled = false;
      String? reminderTime;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ReminderTimePicker(
                  isEnabled: isEnabled,
                  reminderTime: reminderTime,
                  onEnabledChanged: (val) {
                    setState(() {
                      isEnabled = val;
                    });
                  },
                  onTimeChanged: (time) {
                    setState(() {
                      reminderTime = time;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Habit Reminder'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Reminder Time'), findsNothing);

      // Toggle switch to enabled
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(isEnabled, isTrue);
      expect(reminderTime, equals('08:00'));
      expect(find.text('Reminder Time'), findsOneWidget);
    });
  });
}
