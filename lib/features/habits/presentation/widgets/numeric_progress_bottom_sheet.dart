import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../extensions/habit_color_extension.dart';
import '../extensions/habit_icon_extension.dart';
import '../providers/use_case_providers.dart';

/// Modal bottom sheet for logging progress on numeric habits.
/// Features a Material Slider, direct numeric text editing, stepper buttons (+/-),
/// quick add chips (+1, +5, Target), real-time progress bar, and Goal Reached status.
class NumericProgressBottomSheet extends ConsumerStatefulWidget {
  final Habit habit;
  final HabitLog? initialLog;
  final DateTime? targetDate;

  const NumericProgressBottomSheet({
    super.key,
    required this.habit,
    this.initialLog,
    this.targetDate,
  });

  static Future<void> show(
    BuildContext context, {
    required Habit habit,
    HabitLog? initialLog,
    DateTime? targetDate,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NumericProgressBottomSheet(
        habit: habit,
        initialLog: initialLog,
        targetDate: targetDate,
      ),
    );
  }

  @override
  ConsumerState<NumericProgressBottomSheet> createState() =>
      _NumericProgressBottomSheetState();
}

class _NumericProgressBottomSheetState
    extends ConsumerState<NumericProgressBottomSheet> {
  late TextEditingController _controller;
  int _currentValue = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final target = widget.habit.targetCount;
    final initialVal = widget.initialLog?.currentValue ?? 0;
    _currentValue = initialVal.clamp(0, target > 0 ? target : 1);
    _controller = TextEditingController(text: _currentValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    final target = widget.habit.targetCount;
    final clamped = newValue.clamp(0, target > 0 ? target : 1);
    HapticFeedback.lightImpact();
    setState(() {
      _currentValue = clamped;
      _controller.text = clamped.toString();
      _errorMessage = null;
    });
  }

  void _increment(int delta) {
    _updateValue(_currentValue + delta);
  }

  void _decrement() {
    if (_currentValue > 0) {
      _updateValue(_currentValue - 1);
    }
  }

  Future<void> _submit() async {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed < 0) {
      setState(() {
        _errorMessage = 'Please enter a valid non-negative number';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.mediumImpact();
      final useCase = ref.read(logHabitProgressUseCaseProvider);
      await useCase.execute(
        habitId: widget.habit.id,
        targetDate: widget.targetDate,
        value: parsed,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.habit.color.color;
    final targetCount = widget.habit.targetCount;
    final mediaQuery = MediaQuery.of(context);
    final isGoalReached = _currentValue >= targetCount && targetCount > 0;
    final progressFraction = targetCount > 0
        ? (_currentValue / targetCount).clamp(0.0, 1.0)
        : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: mediaQuery.size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Scrollable Body Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.habit.icon.toIconData,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.habit.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$_currentValue / $targetCount',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isGoalReached)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Goal Reached 🎉',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Semantics(
                            button: true,
                            label: 'Close progress log',
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              tooltip: 'Cancel',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Visual Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          minHeight: 8,
                          backgroundColor: accentColor.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stepper & Direct Input Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            button: true,
                            label: 'Decrement count',
                            child: IconButton.filledTonal(
                              onPressed: _currentValue > 0 ? _decrement : null,
                              icon: const Icon(Icons.remove),
                              tooltip: 'Decrement',
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Direct Number Editing input
                          SizedBox(
                            width: 110,
                            child: Semantics(
                              label: 'Progress value input field',
                              value: _currentValue.toString(),
                              hint: 'Tap to edit number directly',
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                ),
                                onChanged: (text) {
                                  final val = int.tryParse(text);
                                  if (val != null) {
                                    final clamped = val.clamp(0, targetCount > 0 ? targetCount : 1);
                                    setState(() {
                                      _currentValue = clamped;
                                      _errorMessage = null;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Semantics(
                            button: true,
                            label: 'Increment count',
                            child: IconButton.filledTonal(
                              onPressed: _currentValue < targetCount ? () => _increment(1) : null,
                              icon: const Icon(Icons.add),
                              tooltip: 'Increment',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Material Slider
                      Semantics(
                        label: 'Progress slider',
                        value: '$_currentValue out of $targetCount',
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: accentColor,
                            thumbColor: accentColor,
                            overlayColor: accentColor.withValues(alpha: 0.2),
                          ),
                          child: Slider(
                            value: _currentValue.toDouble().clamp(0.0, targetCount > 0 ? targetCount.toDouble() : 1.0),
                            min: 0.0,
                            max: targetCount > 0 ? targetCount.toDouble() : 1.0,
                            divisions: targetCount > 0 ? targetCount : 1,
                            label: _currentValue.toString(),
                            onChanged: (val) {
                              _updateValue(val.round());
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Quick Add Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            button: true,
                            label: 'Add 1 to progress',
                            child: ActionChip(
                              label: const Text('+1'),
                              onPressed: _currentValue < targetCount ? () => _increment(1) : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Semantics(
                            button: true,
                            label: 'Add 5 to progress',
                            child: ActionChip(
                              label: const Text('+5'),
                              onPressed: _currentValue < targetCount ? () => _increment(5) : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Semantics(
                            button: true,
                            label: 'Set progress to target $targetCount',
                            child: ActionChip(
                              label: const Text('Target'),
                              onPressed: () => _updateValue(targetCount),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sticky Action Button
              Semantics(
                button: true,
                label: 'Save progress',
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: accentColor,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Progress'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
