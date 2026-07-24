import 'package:logger/logger.dart';

/// Abstract logging contract for the application.
abstract class AppLogger {
  void debug(String message, [dynamic error, StackTrace? stackTrace]);
  void info(String message, [dynamic error, StackTrace? stackTrace]);
  void warning(String message, [dynamic error, StackTrace? stackTrace]);
  void error(String message, [dynamic error, StackTrace? stackTrace]);
  void fatal(String message, [dynamic error, StackTrace? stackTrace]);
}

/// Production implementation of [AppLogger] utilizing the logger package.
class ProductionLogger implements AppLogger {
  ProductionLogger({required this.enableLogging})
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 8,
            lineLength: 100,
            colors: true,
            printEmojis: true,
          ),
          level: enableLogging ? Level.trace : Level.off,
        );

  final bool enableLogging;
  final Logger _logger;

  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (enableLogging) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  @override
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (enableLogging) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }
}
