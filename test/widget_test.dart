import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/features/settings/presentation/providers/vacation_mode_provider.dart';

import 'features/settings/presentation/providers/vacation_mode_provider_test.dart';

void main() {
  testWidgets('App loads and displays Habit Tracker header', (WidgetTester tester) async {
    final fakeVacationRepo = FakeVacationModeRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vacationModeRepositoryProvider.overrideWithValue(fakeVacationRepo),
        ],
        child: const App(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Habit Tracker'), findsOneWidget);
  });
}
