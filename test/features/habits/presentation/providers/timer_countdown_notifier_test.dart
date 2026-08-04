import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_color.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_frequency.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_type.dart';
import 'package:habit_tracker/features/habits/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habits/presentation/providers/timer_countdown_notifier.dart';

import '../../domain/usecases/log_habit_progress_use_case_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late InMemoryHabitRepository repository;
  final now = DateTime(2026, 7, 28);
  final habit = Habit(
    id: 'h-timer-cntdwn',
    title: 'Focus Session',
    habitType: HabitType.timer,
    targetCount: 10, // 10 seconds for test
    color: HabitColor.purple,
    frequency: HabitFrequency.daily,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    repository = InMemoryHabitRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
    );
  }

  group('TimerCountdownNotifier Unit Tests', () {
    test('initial state sets remainingSeconds equal to targetSeconds', () {
      final container = makeContainer();
      addTearDown(container.dispose);

      final params = TimerCountdownParams(habit: habit);
      final state = container.read(timerCountdownProvider(params));

      expect(state.remainingSeconds, 10);
      expect(state.targetSeconds, 10);
      expect(state.status, TimerCountdownStatus.initial);
    });

    test('start, pause, resume, reset transition timer status correctly', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final params = TimerCountdownParams(habit: habit);
      final notifier = container.read(timerCountdownProvider(params).notifier);

      notifier.start();
      expect(container.read(timerCountdownProvider(params)).status, TimerCountdownStatus.running);

      notifier.pause();
      expect(container.read(timerCountdownProvider(params)).status, TimerCountdownStatus.paused);

      notifier.start();
      expect(container.read(timerCountdownProvider(params)).status, TimerCountdownStatus.running);

      notifier.reset();
      final state = container.read(timerCountdownProvider(params));
      expect(state.remainingSeconds, 10);
      expect(state.status, TimerCountdownStatus.initial);
    });

    test('timer completes automatically and logs habit progress when timer hits 0', () async {
      await repository.createHabit(habit);
      final container = makeContainer();
      addTearDown(container.dispose);

      final fastHabit = habit.copyWith(targetCount: 1);
      final params = TimerCountdownParams(habit: fastHabit);
      final notifier = container.read(timerCountdownProvider(params).notifier);

      notifier.start();
      await Future<void>.delayed(const Duration(milliseconds: 1200));

      final state = container.read(timerCountdownProvider(params));
      expect(state.status, TimerCountdownStatus.completed);
      expect(state.remainingSeconds, 0);

      final logs = await repository.getLogsForHabit(fastHabit.id);
      expect(logs, hasLength(1));
      expect(logs.first.currentValue, 1);
    });

    test('timer state persists across multiple reads and does not duplicate timers', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final params = TimerCountdownParams(habit: habit);
      final notifier1 = container.read(timerCountdownProvider(params).notifier);
      notifier1.start();

      final notifier2 = container.read(timerCountdownProvider(params).notifier);
      expect(identical(notifier1, notifier2), isTrue);
      expect(container.read(timerCountdownProvider(params)).status, TimerCountdownStatus.running);

      notifier1.pause();
    });
  });
}
