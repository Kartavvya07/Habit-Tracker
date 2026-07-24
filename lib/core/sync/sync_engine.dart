/// Abstract contract defining the sync engine interface for future cloud synchronization.
abstract class SyncEngine {
  /// Initializes the sync engine and local-first change listeners.
  Future<void> initialize();

  /// Triggers a manual sync process.
  Future<void> sync();

  /// Gets the stream of sync status updates.
  Stream<bool> get isSyncing;
}

/// Scaffold implementation of [SyncEngine] for Phase 1 infrastructure.
/// 
/// Contains zero business or cloud logic as required by Phase 1 constraints.
class NoOpSyncEngine implements SyncEngine {
  @override
  Future<void> initialize() async {
    // Scaffold initialization without network operations
  }

  @override
  Future<void> sync() async {
    // Scaffold sync without network operations
  }

  @override
  Stream<bool> get isSyncing => Stream.value(false);
}
