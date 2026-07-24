import 'package:flutter/material.dart';
import '../extensions/habit_icon_extension.dart';

class IconSelector extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  const IconSelector({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: HabitIconOptions.availableIcons.map((iconName) {
            final isSelected = iconName == selectedIcon;
            return Semantics(
              label: '$iconName icon option',
              selected: isSelected,
              button: true,
              child: InkWell(
                onTap: () => onIconSelected(iconName),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Icon(
                    iconName.toIconData,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
