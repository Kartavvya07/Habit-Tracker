import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/vacation_mode_repository.dart';

/// Implementation of [VacationModeRepository] using [SharedPreferences].
class PreferencesVacationModeRepository implements VacationModeRepository {
  static const String _keyVacationMode = 'vacation_mode_enabled';

  final SharedPreferencesAsync _asyncPrefs;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  PreferencesVacationModeRepository({SharedPreferencesAsync? asyncPrefs})
      : _asyncPrefs = asyncPrefs ?? SharedPreferencesAsync();

  @override
  Future<bool> isVacationModeEnabled() async {
    final value = await _asyncPrefs.getBool(_keyVacationMode);
    return value ?? false;
  }

  @override
  Future<void> setVacationMode(bool enabled) async {
    await _asyncPrefs.setBool(_keyVacationMode, enabled);
    _controller.add(enabled);
  }

  @override
  Stream<bool> watchVacationMode() async* {
    final initial = await isVacationModeEnabled();
    yield initial;
    yield* _controller.stream;
  }
}
