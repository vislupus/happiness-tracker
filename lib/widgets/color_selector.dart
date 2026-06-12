import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_dimensions.dart';

/// Shared color selector widget used by both EventsSection and EventsTab.
///
/// Put this file in: lib/widgets/color_selector.dart
class ColorSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ColorSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.paddingS,
      runSpacing: AppDimensions.paddingS,
      children: List.generate(
        AppColors.eventColors.length,
        (index) => _ColorDot(
          index: index,
          isSelected: selectedIndex == index,
          onTap: () => onSelect(index),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.eventColors[index];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDimensions.animationFast,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: AppColors.needsLightText(index)
                    ? Colors.white
                    : AppColors.textPrimary,
                size: 16,
              )
            : null,
      ),
    );
  }
}
