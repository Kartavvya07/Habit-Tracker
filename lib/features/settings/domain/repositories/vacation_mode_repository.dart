import 'dart:async';

/// Repository interface for persisting and observing global Vacation Mode status.
abstract class VacationModeRepository {
  /// Returns whether Vacation Mode is currently enabled.
  Future<bool> isVacationModeEnabled();

  /// Updates the Vacation Mode status.
  Future<void> setVacationMode(bool enabled);

  /// Stream of Vacation Mode status updates.
  Stream<bool> watchVacationMode();
}
