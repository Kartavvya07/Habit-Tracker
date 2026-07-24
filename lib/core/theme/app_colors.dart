import 'package:flutter/material.dart';

/// Constitutional color tokens for the Habit Tracker application.
/// 
/// Strictly derived from PROJECT_SPECIFICATION_FINAL.md Section 15.
abstract class AppColors {
  // Constitutional Core Colors
  static const Color primary = Color(0xFF2563EB); // #2563EB - Blue 600
  static const Color success = Color(0xFF10B981); // #10B981 - Emerald 500
  static const Color error = Color(0xFFEF4444);   // #EF4444 - Red 500
  static const Color warning = Color(0xFFF59E0B); // #F59E0B - Amber 500

  // Light Palette
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF0F172A);
  static const Color onSurfaceLight = Color(0xFF1E293B);
  static const Color outlineLight = Color(0xFFE2E8F0);

  // Dark Palette (Sleek Dark Mode)
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF131B2E);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);
  static const Color onBackgroundDark = Color(0xFFF8FAFC);
  static const Color onSurfaceDark = Color(0xFFE2E8F0);
  static const Color outlineDark = Color(0xFF1E293B);
}
