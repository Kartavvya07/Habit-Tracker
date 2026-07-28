import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/dashboard/presentation/widgets/daily_summary_card.dart';
import 'package:habit_tracker/features/habits/domain/entities/daily_completion_stats.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_completion_provider.dart';
import 'package:habit_tracker/features/settings/presentation/providers/vacation_mode_provider.dart';

import '../../../settings/presentation/providers/vacation_mode_provider_test.dart';

void main() {
  group('DailySummaryCard Widget Tests', () {
    late FakeVacationModeRepository vacationRepository;

    setUp(() {
      vacationRepository = FakeVacationModeRepository();
    });

    testWidgets('renders daily overview header and stats', (tester) async {
      final container = ProviderContainer(
        overrides: [
          vacationModeRepositoryProvider.overrideWithValue(vacationRepository),
          todayCompletionsProvider.overrideWith(
            (ref) => Stream.value(
              DailyCompletionStats(
                date: DateTime.now(),
                totalHabits: 4,
                completedHabits: 2,
                completionPercentage: 0.5,
                isFullyCompleted: false,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DailySummaryCard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Today\'s Overview'), findsOneWidget);
      expect(find.text('2 of 4 habits completed'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);

      container.dispose();
    });

    testWidgets('renders celebratory text when fully completed', (tester) async {
      final container = ProviderContainer(
        overrides: [
          vacationModeRepositoryProvider.overrideWithValue(vacationRepository),
          todayCompletionsProvider.overrideWith(
            (ref) => Stream.value(
              DailyCompletionStats(
                date: DateTime.now(),
                totalHabits: 3,
                completedHabits: 3,
                completionPercentage: 1.0,
                isFullyCompleted: true,
              ),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: DailySummaryCard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🎉 All habits completed today!'), findsOneWidget);

      container.dispose();
    });
  });
}
