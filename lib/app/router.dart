import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/habits/domain/entities/habit.dart';
import '../features/habits/presentation/screens/archived_habits_screen.dart';
import '../features/habits/presentation/screens/create_habit_screen.dart';
import '../features/habits/presentation/screens/edit_habit_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/create-habit',
      builder: (context, state) => const CreateHabitScreen(),
    ),
    GoRoute(
      path: '/edit-habit',
      builder: (context, state) {
        final habit = state.extra as Habit;
        return EditHabitScreen(habit: habit);
      },
    ),
    GoRoute(
      path: '/archived-habits',
      builder: (context, state) => const ArchivedHabitsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
