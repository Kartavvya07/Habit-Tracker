/// Represents the runtime deployment environment for the application.
enum AppEnvironment {
  /// Development environment for local testing and debugging.
  dev,

  /// Staging environment for pre-release validation.
  staging,

  /// Production environment for public releases.
  prod;

  /// Returns `true` if current environment is development.
  bool get isDev => this == AppEnvironment.dev;

  /// Returns `true` if current environment is staging.
  bool get isStaging => this == AppEnvironment.staging;

  /// Returns `true` if current environment is production.
  bool get isProd => this == AppEnvironment.prod;

  /// Returns a human-readable display name for the environment.
  String get displayName {
    switch (this) {
      case AppEnvironment.dev:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.prod:
        return 'Production';
    }
  }
}
