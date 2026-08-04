import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/habit_duration.dart';

/// Material 3 reusable Duration Picker widget featuring iOS/Android style wheel pickers
/// for Hours, Minutes, and Seconds with snap behavior and accessibility support.
class DurationPicker extends StatefulWidget {
  final HabitDuration initialDuration;
  final ValueChanged<HabitDuration> onChanged;

  const DurationPicker({
    super.key,
    required this.initialDuration,
    required this.onChanged,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late int _hours;
  late int _minutes;
  late int _seconds;

  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.hours.clamp(0, 99);
    _minutes = widget.initialDuration.minutes.clamp(0, 59);
    _seconds = widget.initialDuration.seconds.clamp(0, 59);

    _hoursController = FixedExtentScrollController(initialItem: _hours);
    _minutesController = FixedExtentScrollController(initialItem: _minutes);
    _secondsController = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final newDuration = HabitDuration.fromHMSS(_hours, _minutes, _seconds);
    widget.onChanged(newDuration);
  }

  Widget _buildWheelColumn({
    required String label,
    required int maxValue,
    required int currentValue,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: Semantics(
              label: '$label scroll wheel',
              value: '$currentValue $label',
              child: CupertinoPicker.builder(
                scrollController: controller,
                itemExtent: 36,
                diameterRatio: 1.1,
                magnification: 1.15,
                useMagnifier: true,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                ),
                onSelectedItemChanged: (index) {
                  HapticFeedback.selectionClick();
                  onSelected(index);
                },
                childCount: maxValue + 1,
                itemBuilder: (context, index) {
                  final isSelected = index == currentValue;
                  return Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentDuration = HabitDuration.fromHMSS(_hours, _minutes, _seconds);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header summary badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currentDuration.formatted(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Wheel pickers row
          Row(
            children: [
              _buildWheelColumn(
                label: 'Hours',
                maxValue: 99,
                currentValue: _hours,
                controller: _hoursController,
                onSelected: (val) {
                  setState(() {
                    _hours = val;
                  });
                  _notifyChange();
                },
              ),
              const Text(
                ':',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              _buildWheelColumn(
                label: 'Minutes',
                maxValue: 59,
                currentValue: _minutes,
                controller: _minutesController,
                onSelected: (val) {
                  setState(() {
                    _minutes = val;
                  });
                  _notifyChange();
                },
              ),
              const Text(
                ':',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              _buildWheelColumn(
                label: 'Seconds',
                maxValue: 59,
                currentValue: _seconds,
                controller: _secondsController,
                onSelected: (val) {
                  setState(() {
                    _seconds = val;
                  });
                  _notifyChange();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
