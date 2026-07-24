import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection with environment configuration
  await configureDependencies(config: AppConfig.development());

  // Configure global BLoC lifecycle observer
  final logger = getIt<AppLogger>();
  Bloc.observer = AppBlocObserver(logger);

  logger.info('Application infrastructure initialized successfully.');

  runApp(const HabitTrackerApp());
}

/// Root widget of the Habit Tracker application.
class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = getIt<AppConfig>();

    return MaterialApp.router(
      title: appConfig.appName,
      debugShowCheckedModeBanner: appConfig.environment.isDev,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
