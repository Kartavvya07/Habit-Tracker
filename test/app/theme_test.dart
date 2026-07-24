import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app/theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('lightTheme configures Material 3 and light brightness', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.light));
    });

    test('darkTheme configures Material 3 and dark brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, equals(Brightness.dark));
    });
  });
}
