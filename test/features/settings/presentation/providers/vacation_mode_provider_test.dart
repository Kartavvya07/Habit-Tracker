import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/settings/domain/repositories/vacation_mode_repository.dart';
import 'package:habit_tracker/features/settings/presentation/providers/vacation_mode_provider.dart';

class FakeVacationModeRepository implements VacationModeRepository {
  bool _enabled = false;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  FakeVacationModeRepository({bool initial = false}) : _enabled = initial;

  @override
  Future<bool> isVacationModeEnabled() async => _enabled;

  @override
  Future<void> setVacationMode(bool enabled) async {
    _enabled = enabled;
    _controller.add(enabled);
  }

  @override
  Stream<bool> watchVacationMode() async* {
    yield _enabled;
    yield* _controller.stream;
  }
}

void main() {
  group('VacationModeNotifier & Provider Tests', () {
    late FakeVacationModeRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = FakeVacationModeRepository(initial: false);
      container = ProviderContainer(
        overrides: [
          vacationModeRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state defaults to false and loads from repository', () async {
      final state = container.read(vacationModeProvider);
      expect(state, isFalse);
    });

    test('enableVacationMode sets state to true and updates repository', () async {
      final notifier = container.read(vacationModeProvider.notifier);
      await notifier.enableVacationMode();

      expect(container.read(vacationModeProvider), isTrue);
      expect(await repository.isVacationModeEnabled(), isTrue);
    });

    test('disableVacationMode sets state to false', () async {
      final notifier = container.read(vacationModeProvider.notifier);
      await notifier.enableVacationMode();
      expect(container.read(vacationModeProvider), isTrue);

      await notifier.disableVacationMode();
      expect(container.read(vacationModeProvider), isFalse);
      expect(await repository.isVacationModeEnabled(), isFalse);
    });

    test('toggleVacationMode toggles state back and forth', () async {
      final notifier = container.read(vacationModeProvider.notifier);

      await notifier.toggleVacationMode();
      expect(container.read(vacationModeProvider), isTrue);

      await notifier.toggleVacationMode();
      expect(container.read(vacationModeProvider), isFalse);
    });

    test('restoration after restart loads persisted enabled state', () async {
      final persistedRepository = FakeVacationModeRepository(initial: true);
      final newContainer = ProviderContainer(
        overrides: [
          vacationModeRepositoryProvider.overrideWithValue(persistedRepository),
        ],
      );

      newContainer.read(vacationModeProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(newContainer.read(vacationModeProvider), isTrue);
      newContainer.dispose();
    });


  });
}
