import 'package:flutter/material.dart';

abstract class AppTheme {
  static const _primarySeed = Color(0xFF635BFF); // Refined modern indigo

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F9FE),
      surfaceContainerLow: const Color(0xFFF1F3FB),
      surfaceContainerHigh: const Color(0xFFE5E7F3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Typography adjustments
      typography: Typography.material2021(),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      // Button Themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
      surface: const Color(0xFF12131A),
      surfaceContainerLow: const Color(0xFF1B1C26),
      surfaceContainerHigh: const Color(0xFF272938),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Typography
      typography: Typography.material2021(),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      // Button Themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        showDragHandle: true,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
    );
  }
}

