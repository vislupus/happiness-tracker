import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';

/// Calendar header with month/year and navigation arrows
class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.calendarHeaderHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
      ),
      decoration: const BoxDecoration(
        color: AppColors.calendarHeaderBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.radiusL),
          topRight: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous month button
          _NavigationButton(
            icon: Icons.chevron_left,
            onTap: onPreviousMonth,
          ),
          
          // Month and year
          Text(
            AppStrings.getMonthYear(currentMonth.month, currentMonth.year),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppDimensions.calendarMonthFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Next month button
          _NavigationButton(
            icon: Icons.chevron_right,
            onTap: onNextMonth,
          ),
        ],
      ),
    );
  }
}

/// Navigation button for previous/next month
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
          ),
          child: Icon(
            icon,
            color: AppColors.iconPrimary,
            size: AppDimensions.iconL,
          ),
        ),
      ),
    );
  }
}