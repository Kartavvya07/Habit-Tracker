import 'package:flutter/material.dart';

/// Constitutional corner radius tokens for the Habit Tracker application.
/// 
/// Default radius is 16dp as specified in PROJECT_SPECIFICATION_FINAL.md Section 15.
abstract class AppRadius {
  static const double smValue = 8.0;
  static const double mdValue = 16.0; // Constitutional Default
  static const double lgValue = 24.0;
  static const double xlValue = 32.0;

  static const Radius sm = Radius.circular(smValue);
  static const Radius md = Radius.circular(mdValue);
  static const Radius lg = Radius.circular(lgValue);
  static const Radius xl = Radius.circular(xlValue);

  static const BorderRadius borderSm = BorderRadius.all(sm);
  static const BorderRadius borderMd = BorderRadius.all(md);
  static const BorderRadius borderLg = BorderRadius.all(lg);
  static const BorderRadius borderXl = BorderRadius.all(xl);
}
