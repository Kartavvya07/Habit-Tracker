import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('LightTheme configures Material 3 and constitutional primary color', () {
      final theme = AppTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.brightness, equals(Brightness.light));
    });

    test('DarkTheme configures Material 3 and constitutional primary color', () {
      final theme = AppTheme.darkTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('AppRadius md default value equals 16dp', () {
      expect(AppRadius.mdValue, equals(16.0));
      expect(AppRadius.md, equals(const Radius.circular(16.0)));
    });
  });
}
