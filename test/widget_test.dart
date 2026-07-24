import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/app/app.dart';

void main() {
  testWidgets('App loads and displays Habit Tracker header', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    expect(find.text('Habit Tracker'), findsOneWidget);
  });
}
