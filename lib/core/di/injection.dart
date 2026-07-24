import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../database/app_database.dart';
import '../logging/app_logger.dart';
import '../sync/sync_engine.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({AppConfig? config}) async {
  final appConfig = config ?? AppConfig.development();

  // Register Core Configuration
  getIt.registerSingleton<AppConfig>(appConfig);

  // Register Production Logging
  final logger = ProductionLogger(enableLogging: appConfig.enableLogging);
  getIt.registerSingleton<AppLogger>(logger);

  // Register Drift Database
  final database = AppDatabase(appConfig.databaseName);
  getIt.registerSingleton<AppDatabase>(database);

  // Register Sync Engine Scaffold
  final syncEngine = NoOpSyncEngine();
  getIt.registerSingleton<SyncEngine>(syncEngine);

  // Run generated injectable registrations
  getIt.init();
}
