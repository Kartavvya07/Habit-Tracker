import 'package:equatable/equatable.dart';
import 'environment.dart';

/// Immutable configuration object providing global configuration flags.
class AppConfig extends Equatable {
  const AppConfig({
    required this.environment,
    required this.appName,
    required this.enableLogging,
    required this.databaseName,
    this.apiBaseUrl,
  });

  /// Factory constructor for development configuration.
  factory AppConfig.development() {
    return const AppConfig(
      environment: AppEnvironment.dev,
      appName: 'Habit Tracker (Dev)',
      enableLogging: true,
      databaseName: 'habit_tracker_dev.db',
      apiBaseUrl: 'https://api.dev.habittracker.internal',
    );
  }

  /// Factory constructor for production configuration.
  factory AppConfig.production() {
    return const AppConfig(
      environment: AppEnvironment.prod,
      appName: 'Habit Tracker',
      enableLogging: false,
      databaseName: 'habit_tracker_prod.db',
      apiBaseUrl: 'https://api.habittracker.app',
    );
  }

  final AppEnvironment environment;
  final String appName;
  final bool enableLogging;
  final String databaseName;
  final String? apiBaseUrl;

  @override
  List<Object?> get props => [
        environment,
        appName,
        enableLogging,
        databaseName,
        apiBaseUrl,
      ];
}
