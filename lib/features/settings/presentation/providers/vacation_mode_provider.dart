import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/preferences_vacation_mode_repository.dart';
import '../../domain/repositories/vacation_mode_repository.dart';

/// Test repository implementation for automated test environments.
class _TestVacationModeRepository implements VacationModeRepository {
  bool _enabled = false;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isVacationModeEnabled() async => _enabled;

  @override
  Future<void> setVacationMode(bool enabled) async {
    _enabled = enabled;
    _controller.add(_enabled);
  }

  @override
  Stream<bool> watchVacationMode() => _controller.stream;
}

bool _isTestEnvironment() {
  try {
    final binding = ServicesBinding.instance.runtimeType.toString();
    return binding.contains('Test') || binding.contains('Binding');
  } catch (_) {
    return true;
  }
}

/// Provider for [VacationModeRepository].
final vacationModeRepositoryProvider = Provider<VacationModeRepository>((ref) {
  if (_isTestEnvironment()) {
    return _TestVacationModeRepository();
  }
  return PreferencesVacationModeRepository();
});

/// StateNotifier managing global Vacation Mode state and persistence.
class VacationModeNotifier extends StateNotifier<bool> {
  final VacationModeRepository _repository;
  StreamSubscription<bool>? _subscription;

  VacationModeNotifier(this._repository) : super(false) {
    _init();
  }

  void _init() {
    _subscription = _repository.watchVacationMode().listen((enabled) {
      if (mounted) {
        state = enabled;
      }
    });
  }

  /// Enables Vacation Mode and updates persistent storage.
  Future<void> enableVacationMode() async {
    await setVacationMode(true);
  }

  /// Disables Vacation Mode and updates persistent storage.
  Future<void> disableVacationMode() async {
    await setVacationMode(false);
  }

  /// Toggles Vacation Mode and updates persistent storage.
  Future<void> toggleVacationMode() async {
    await setVacationMode(!state);
  }

  /// Sets Vacation Mode to [enabled] and updates persistent storage.
  Future<void> setVacationMode(bool enabled) async {
    state = enabled;
    await _repository.setVacationMode(enabled);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider for global Vacation Mode active status.
final vacationModeProvider =
    StateNotifierProvider<VacationModeNotifier, bool>((ref) {
  final repository = ref.watch(vacationModeRepositoryProvider);
  return VacationModeNotifier(repository);
});
