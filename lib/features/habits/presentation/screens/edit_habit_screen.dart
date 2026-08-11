import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_duration.dart';
import '../../domain/entities/habit_frequency.dart';
import '../../domain/entities/habit_type.dart';
import '../extensions/habit_color_extension.dart';
import '../providers/edit_habit_notifier.dart';
import '../widgets/color_selector.dart';
import '../widgets/duration_picker.dart';
import '../widgets/icon_selector.dart';
import '../widgets/reminder_time_picker.dart';

class EditHabitScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const EditHabitScreen({super.key, required this.habit});

  @override
  ConsumerState<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends ConsumerState<EditHabitScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetCountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _targetCountController = TextEditingController(text: widget.habit.targetCount.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  void _onSavePressed() async {
    final success = await ref.read(editHabitProvider(widget.habit).notifier).saveHabit();
    if (success && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  void _onArchiveTogglePressed() async {
    final state = ref.read(editHabitProvider(widget.habit));
    final notifier = ref.read(editHabitProvider(widget.habit).notifier);

    final success = state.isArchived ? await notifier.restoreHabit() : await notifier.archiveHabit();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.isArchived ? 'Habit restored to active dashboard.' : 'Habit moved to archive.'),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editHabitProvider(widget.habit));
    final notifier = ref.read(editHabitProvider(widget.habit).notifier);
    final theme = Theme.of(context);

    ref.listen(editHabitProvider(widget.habit), (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(state.isArchived ? Icons.unarchive : Icons.archive_outlined),
            tooltip: state.isArchived ? 'Restore Habit' : 'Archive Habit',
            onPressed: state.isSubmitting ? null : _onArchiveTogglePressed,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                onChanged: notifier.updateTitle,
                decoration: InputDecoration(
                  labelText: 'Habit Title',
                  hintText: 'e.g., Morning Workout',
                  errorText: state.titleError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit_note),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                onChanged: notifier.updateDescription,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g., Do 30 minutes of cardio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              Text(
                'Frequency',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<HabitFrequency>(
                segments: HabitFrequency.values.map((freq) {
                  return ButtonSegment<HabitFrequency>(
                    value: freq,
                    label: Text(freq.name[0].toUpperCase() + freq.name.substring(1)),
                  );
                }).toList(),
                selected: {state.frequency},
                onSelectionChanged: (Set<HabitFrequency> selected) {
                  notifier.updateFrequency(selected.first);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Habit Type',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<HabitType>(
                segments: HabitType.values.map((type) {
                  return ButtonSegment<HabitType>(
                    value: type,
                    label: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                  );
                }).toList(),
                selected: {state.habitType},
                onSelectionChanged: (Set<HabitType> selected) {
                  notifier.updateHabitType(selected.first);
                  if (selected.first == HabitType.boolean) {
                    _targetCountController.text = '1';
                  }
                },
              ),
              const SizedBox(height: 20),
              if (state.habitType == HabitType.numeric) ...[
                TextField(
                  controller: _targetCountController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val) ?? 0;
                    notifier.updateTargetCount(parsed);
                  },
                  decoration: InputDecoration(
                    labelText: 'Target Count',
                    errorText: state.targetCountError,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (state.habitType == HabitType.timer) ...[
                Text(
                  'Target Duration',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DurationPicker(
                  initialDuration: HabitDuration(
                    state.targetCount <= 0 ? 900 : state.targetCount,
                  ),
                  onChanged: (duration) {
                    notifier.updateTargetCount(duration.totalSeconds);
                  },
                ),
                if (state.targetCountError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.targetCountError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 20),
              ],
              ReminderTimePicker(
                isEnabled: state.isReminderEnabled,
                reminderTime: state.reminderTime,
                onEnabledChanged: notifier.updateReminderEnabled,
                onTimeChanged: notifier.updateReminderTime,
              ),
              const SizedBox(height: 20),
              ColorSelector(
                selectedColor: state.color,
                onColorSelected: notifier.updateColor,
              ),
              const SizedBox(height: 20),
              IconSelector(
                selectedIcon: state.icon,
                onIconSelected: notifier.updateIcon,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.isSubmitting ? null : _onSavePressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: state.color.color,
                        foregroundColor: Colors.white,
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Habit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
