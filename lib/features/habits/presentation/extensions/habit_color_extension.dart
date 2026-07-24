import 'package:flutter/material.dart';
import '../../domain/entities/habit_color.dart';

extension HabitColorX on HabitColor {
  Color get color {
    switch (this) {
      case HabitColor.blue:
        return const Color(0xFF2563EB);
      case HabitColor.green:
        return const Color(0xFF10B981);
      case HabitColor.purple:
        return const Color(0xFF8B5CF6);
      case HabitColor.orange:
        return const Color(0xFFF59E0B);
      case HabitColor.red:
        return const Color(0xFFEF4444);
      case HabitColor.teal:
        return const Color(0xFF14B8A6);
      case HabitColor.pink:
        return const Color(0xFFEC4899);
      case HabitColor.indigo:
        return const Color(0xFF6366F1);
    }
  }

  String get displayName {
    switch (this) {
      case HabitColor.blue:
        return 'Blue';
      case HabitColor.green:
        return 'Green';
      case HabitColor.purple:
        return 'Purple';
      case HabitColor.orange:
        return 'Orange';
      case HabitColor.red:
        return 'Red';
      case HabitColor.teal:
        return 'Teal';
      case HabitColor.pink:
        return 'Pink';
      case HabitColor.indigo:
        return 'Indigo';
    }
  }
}
