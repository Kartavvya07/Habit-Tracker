import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../settings/presentation/providers/vacation_mode_provider.dart';
import '../../../habits/presentation/providers/use_case_providers.dart';
import '../providers/dashboard_provider.dart';
import '../providers/dashboard_state.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/vacation_banner.dart';

/// The main Dashboard screen displaying the user's habit feed.
/// Observes [dashboardProvider] only and renders presentation states.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final isVacationModeActive = ref.watch(vacationModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Archived Habits',
            onPressed: () => context.push('/archived-habits'),
          ),
          Semantics(
            button: true,
            label: 'Toggle Vacation Mode',
            child: IconButton(
              icon: Icon(
                isVacationModeActive
                    ? Icons.beach_access_rounded
                    : Icons.beach_access_outlined,
                color: isVacationModeActive
                    ? theme.colorScheme.tertiary
                    : null,
              ),
              tooltip: isVacationModeActive
                  ? 'Vacation Mode Active'
                  : 'Turn on Vacation Mode',
              onPressed: () {
                ref.read(vacationModeProvider.notifier).toggleVacationMode();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _buildBody(context, ref, state),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-habit'),
        icon: const Icon(Icons.add),
        label: const Text('Create Habit'),
        tooltip: 'Create Habit',
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DashboardState state) {
    switch (state) {
      case DashboardLoading():
        return const _DashboardLoadingView();
      case DashboardEmpty():
        return _DashboardEmptyView(
          onCreateHabit: () => context.push('/create-habit'),
        );
      case DashboardLoaded(:final habits):
        return _DashboardLoadedView(habits: habits);
      case DashboardError(:final message):
        return _DashboardErrorView(
          message: message,
          onRetry: () => ref.invalidate(habitsStreamProvider),
        );
    }
  }
}

class _DashboardLoadingView extends StatelessWidget {
  const _DashboardLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Loading habits',
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _DashboardEmptyView extends StatelessWidget {
  final VoidCallback onCreateHabit;

  const _DashboardEmptyView({required this.onCreateHabit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start building your routines today by creating your first habit.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onCreateHabit,
              icon: const Icon(Icons.add),
              label: const Text('Create Habit'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoadedView extends ConsumerWidget {
  final List<Habit> habits;

  const _DashboardLoadedView({required this.habits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVacationModeActive = ref.watch(vacationModeProvider);
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 88),
      itemCount: habits.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return VacationBanner(
            isActive: isVacationModeActive,
            onToggle: () {
              ref.read(vacationModeProvider.notifier).toggleVacationMode();
            },
          );
        }
        if (index == 1) {
          return const DailySummaryCard();
        }
        final habit = habits[index - 2];
        return Dismissible(
          key: ValueKey('dismissible-${habit.id}'),
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.edit, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Archive',
                  style: TextStyle(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.archive_outlined, color: theme.colorScheme.onTertiaryContainer),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              context.push('/edit-habit', extra: habit);
              return false;
            }
            return direction == DismissDirection.endToStart;
          },
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final messenger = ScaffoldMessenger.of(context);
              final archiveUseCase = ref.read(archiveHabitUseCaseProvider);
              await archiveUseCase.execute(habit.id);

              messenger.clearSnackBars();
              messenger.showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                  content: const Text('✓ Habit moved to Archived'),
                ),
              );
            }
          },
          child: HabitCard(
            key: ValueKey(habit.id),
            habit: habit,
          ),
        );
      },
    );
  }
}


class _DashboardErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load habits',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
