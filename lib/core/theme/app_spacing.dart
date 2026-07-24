import 'package:flutter/material.dart';

/// Constitutional spacing tokens and helpers for the Habit Tracker application.
/// 
/// Strictly adheres to values 8, 16, 24, 32 from PROJECT_SPECIFICATION_FINAL.md Section 15.
abstract class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;   // Constitutional Spacing Token 8
  static const double md = 16.0;  // Constitutional Spacing Token 16
  static const double lg = 24.0;  // Constitutional Spacing Token 24
  static const double xl = 32.0;  // Constitutional Spacing Token 32

  /// Animation duration design token (300ms default)
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Vertical spacing widgets
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);

  // Horizontal spacing widgets
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
}
