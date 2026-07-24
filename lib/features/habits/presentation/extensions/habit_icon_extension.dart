import 'package:flutter/material.dart';

extension HabitIconX on String {
  IconData get toIconData {
    switch (this) {
      case 'check':
        return Icons.check_circle_outline;
      case 'fitness':
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book_outlined;
      case 'water':
      case 'water_drop':
        return Icons.water_drop_outlined;
      case 'meditation':
      case 'self_improvement':
        return Icons.self_improvement;
      case 'run':
      case 'directions_run':
        return Icons.directions_run;
      case 'sleep':
      case 'bedtime':
        return Icons.bedtime_outlined;
      case 'work':
        return Icons.work_outline;
      case 'code':
        return Icons.code;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.check_circle_outline;
    }
  }
}

abstract class HabitIconOptions {
  static const List<String> availableIcons = [
    'check',
    'fitness_center',
    'book',
    'water_drop',
    'self_improvement',
    'directions_run',
    'bedtime',
    'work',
    'code',
    'restaurant',
  ];
}
