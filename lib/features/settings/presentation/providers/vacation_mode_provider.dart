import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/preferences_vacation_mode_repository.dart';
import '../../domain/repositories/vacation_mode_repository.dart';

/// Provider for [VacationModeRepository].
final vacationModeRepositoryProvider = Provider<VacationModeRepository>((ref) {
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
