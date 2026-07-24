import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/config/app_config.dart';
import 'package:habit_tracker/core/config/environment.dart';

void main() {
  group('AppConfig Tests', () {
    test('Development factory produces valid dev configuration', () {
      final config = AppConfig.development();

      expect(config.environment, equals(AppEnvironment.dev));
      expect(config.environment.isDev, isTrue);
      expect(config.enableLogging, isTrue);
      expect(config.databaseName, equals('habit_tracker_dev.db'));
    });

    test('Production factory produces valid prod configuration', () {
      final config = AppConfig.production();

      expect(config.environment, equals(AppEnvironment.prod));
      expect(config.environment.isProd, isTrue);
      expect(config.enableLogging, isFalse);
      expect(config.databaseName, equals('habit_tracker_prod.db'));
    });
  });
}
