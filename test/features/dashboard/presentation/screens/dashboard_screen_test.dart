import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:habit_tracker/features/dashboard/presentation/providers/dashboard_state.dart';
import 'package:habit_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:habit_tracker/features/dashboard/presentation/widgets/habit_card.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/domain/usecases/archive_habit_use_case.dart';
import 'package:habit_tracker/features/habits/domain/usecases/restore_habit_use_case.dart';
import 'package:habit_tracker/features/habits/presentation/providers/use_case_providers.dart';
import 'package:habit_tracker/features/settings/presentation/providers/vacation_mode_provider.dart';

import '../../../settings/presentation/providers/vacation_mode_provider_test.dart';

class FakeArchiveHabitUseCase extends Fake implements ArchiveHabitUseCase {
  final List<String> archivedIds = [];
  @override
  Future<void> execute(String id) async {
    archivedIds.add(id);
  }
}

class FakeRestoreHabitUseCase extends Fake implements RestoreHabitUseCase {
  final List<String> restoredIds = [];
  @override
  Future<void> execute(String id) async {
    restoredIds.add(id);
  }
}

void main() {
  final now = DateTime(2026, 7, 25);
  final fakeVacationRepository = FakeVacationModeRepository();

  final sampleHabit1 = Habit(
    id: 'habit-1',
    title: 'Habit One (Newer)',
    createdAt: now.add(const Duration(minutes: 10)),
    updatedAt: now.add(const Duration(minutes: 10)),
  );

  final sampleHabit2 = Habit(
    id: 'habit-2',
    title: 'Habit Two (Older)',
    createdAt: now,
    updatedAt: now,
  );

  Widget buildTestableDashboard({
    required List<Override> overrides,
    GoRouter? router,
  }) {
    final testRouter = router ??
        GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/create-habit',
              builder: (context, state) => const Scaffold(
                body: Text('Create Habit Screen Target'),
              ),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        vacationModeRepositoryProvider.overrideWithValue(fakeVacationRepository),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: testRouter,
      ),
    );
  }


  group('DashboardScreen Widget Tests', () {
    testWidgets('renders Loading state indicator', (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(const DashboardLoading()),
          ],
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders Empty state and CTA button', (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(const DashboardEmpty()),
          ],
        ),
      );

      expect(find.text('No habits yet'), findsOneWidget);
      expect(
        find.text('Start building your routines today by creating your first habit.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Create Habit'), findsOneWidget);
    });

    testWidgets('navigates to /create-habit when CTA button in empty state is tapped',
        (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(const DashboardEmpty()),
          ],
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Create Habit'));
      await tester.pumpAndSettle();

      expect(find.text('Create Habit Screen Target'), findsOneWidget);
    });

    testWidgets('navigates to /create-habit when FAB is tapped', (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(const DashboardEmpty()),
          ],
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Create Habit Screen Target'), findsOneWidget);
    });

    testWidgets('renders Loaded state with habit list in repository order', (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(
              DashboardLoaded([sampleHabit1, sampleHabit2]),
            ),
          ],
        ),
      );

      expect(find.byType(HabitCard), findsNWidgets(2));
      expect(find.text('Habit One (Newer)'), findsOneWidget);
      expect(find.text('Habit Two (Older)'), findsOneWidget);

      // Verify order: sampleHabit1 precedes sampleHabit2
      final habit1Rect = tester.getRect(find.text('Habit One (Newer)'));
      final habit2Rect = tester.getRect(find.text('Habit Two (Older)'));
      expect(habit1Rect.top, lessThan(habit2Rect.top));
    });

    testWidgets('renders Error state and Retry button', (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(
              const DashboardError('Database connection failed'),
            ),
          ],
        ),
      );

      expect(find.text('Failed to load habits'), findsOneWidget);
      expect(find.text('Database connection failed'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    });

    testWidgets('automatically refreshes Dashboard when stream emits new habits', (tester) async {
      final controller = StreamController<List<Habit>>();

      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            habitsStreamProvider.overrideWith((ref) => controller.stream),
          ],
        ),
      );

      // Initially in loading state before first stream emission
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Stream emits empty list
      controller.add([]);
      await tester.pump();

      expect(find.text('No habits yet'), findsOneWidget);

      // Stream emits newly created habit
      controller.add([sampleHabit1]);
      await tester.pump();

      expect(find.text('No habits yet'), findsNothing);
      await controller.close();
    });

    testWidgets('renders archived habits button in AppBar', (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(
              DashboardLoaded([sampleHabit1]),
            ),
          ],
        ),
      );

      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    });

    testWidgets('wraps habit card in Dismissible for swipe actions', (tester) async {
      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(
              DashboardLoaded([sampleHabit1]),
            ),
          ],
        ),
      );

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('swiping left archives habit and pressing Undo calls RestoreHabitUseCase',
        (tester) async {
      final fakeArchiveUseCase = FakeArchiveHabitUseCase();
      final fakeRestoreUseCase = FakeRestoreHabitUseCase();

      await tester.pumpWidget(
        buildTestableDashboard(
          overrides: [
            dashboardProvider.overrideWithValue(
              DashboardLoaded([sampleHabit1]),
            ),
            archiveHabitUseCaseProvider.overrideWithValue(fakeArchiveUseCase),
            restoreHabitUseCaseProvider.overrideWithValue(fakeRestoreUseCase),
          ],
        ),
      );

      // Swipe left on Dismissible
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify ArchiveHabitUseCase was called
      expect(fakeArchiveUseCase.archivedIds, contains('habit-1'));

      // Verify SnackBar and Undo action
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Habit One (Newer) archived'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo action
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // Verify RestoreHabitUseCase was called
      expect(fakeRestoreUseCase.restoredIds, contains('habit-1'));
      expect(find.text('Habit One (Newer) restored to dashboard.'), findsOneWidget);
    });
  });
}
