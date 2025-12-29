import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../models/happiness_entry.dart';
import '../../models/event.dart';
import '../../providers/app_provider.dart';

/// Individual day cell in the calendar
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final HappinessEntry? entry;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final averageHappiness = entry?.averageHappiness;
    final hasData = entry?.hasData ?? false;
    
    // Get events for this date (already sorted by created_at from provider)
    final provider = context.watch<AppProvider>();
    final events = provider.getEventsForDate(date);
    
    // Determine background color based on happiness level
    Color backgroundColor = Colors.transparent;
    Color textColor = _getTextColor();
    
    if (hasData && averageHappiness != null && !isSelected) {
      backgroundColor = AppColors.getHappinessColor(averageHappiness);
      textColor = AppColors.getHappinessColorDark(averageHappiness);
    }
    
    if (isSelected) {
      backgroundColor = AppColors.calendarSelectedBackground;
      textColor = AppColors.calendarSelectedText;
    } else if (isToday && !hasData) {
      backgroundColor = AppColors.calendarTodayBackground;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDimensions.animationFast,
        width: AppDimensions.calendarDayCellSize,
        height: AppDimensions.calendarDayCellSize,
        margin: const EdgeInsets.all(AppDimensions.calendarDayCellMargin),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: isToday && !isSelected
                    ? Border.all(
                        color: AppColors.calendarTodayBorder,
                        width: AppDimensions.calendarTodayBorderWidth,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: events.isNotEmpty ? 4 : 0),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: AppDimensions.calendarDayFontSize,
                      fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // Event dots (top) - sorted by creation order
            if (events.isNotEmpty)
              Positioned(
                top: 3,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildEventDots(events, isSelected),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEventDots(List<Event> events, bool isSelected) {
    // Events are already sorted by created_at from the database
    // Show max 3 dots
    final displayEvents = events.take(3).toList();
    
    return displayEvents.map((event) {
      final color = AppColors.getEventColor(event.colorIndex);
      
      return Container(
        width: AppDimensions.calendarEventDotSize,
        height: AppDimensions.calendarEventDotSize,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.calendarEventDotSpacing / 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : color,
          shape: BoxShape.circle,
        ),
      );
    }).toList();
  }

  Color _getTextColor() {
    if (isSelected) {
      return AppColors.calendarSelectedText;
    }
    if (!isCurrentMonth) {
      return AppColors.calendarOtherMonthText;
    }
    return AppColors.calendarDayText;
  }
}