import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../config/app_strings.dart';
import '../../providers/app_provider.dart';
import 'calendar_header.dart';
import 'calendar_day_cell.dart';

/// Main calendar widget with month view
class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late PageController _pageController;
  static const int _initialPage = 1200; // Start in the middle for infinite scroll
  int _currentPage = _initialPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Get month for a given page index
  DateTime _getMonthForPage(int page, DateTime baseMonth) {
    final diff = page - _currentPage;
    return DateTime(baseMonth.year, baseMonth.month + diff, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.calendarBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with month navigation
              CalendarHeader(
                currentMonth: provider.currentMonth,
                onPreviousMonth: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                onNextMonth: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              
              // Weekday labels
              _buildWeekdayLabels(),
              
              // Calendar grid with PageView
              SizedBox(
                height: 6 * (AppDimensions.calendarDayCellSize + AppDimensions.calendarDayCellMargin * 2) + AppDimensions.paddingS * 2,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    final diff = page - _currentPage;
                    _currentPage = page;
                    
                    if (diff > 0) {
                      provider.nextMonth();
                    } else if (diff < 0) {
                      provider.previousMonth();
                    }
                  },
                  itemBuilder: (context, page) {
                    final monthToShow = _getMonthForPage(page, provider.currentMonth);
                    return _buildCalendarGrid(context, provider, monthToShow);
                  },
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingS),
            ],
          ),
        );
      },
    );
  }

  /// Build weekday labels row
  Widget _buildWeekdayLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: AppStrings.weekdaysShort.map((day) {
          return SizedBox(
            width: AppDimensions.calendarDayCellSize,
            height: AppDimensions.calendarWeekdayHeight,
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  color: AppColors.calendarWeekdayText,
                  fontSize: AppDimensions.calendarWeekdayFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build the calendar grid for a specific month
  Widget _buildCalendarGrid(BuildContext context, AppProvider provider, DateTime month) {
    final weeks = _getWeeksInMonth(month);
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingS),
      child: Column(
        children: weeks.map((week) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((date) {
              return CalendarDayCell(
                date: date,
                isCurrentMonth: date.month == month.month,
                isToday: provider.isToday(date),
                isSelected: provider.isSelected(date),
                entry: provider.getEntryForDate(date),
                onTap: () => provider.selectDate(date),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  /// Get all weeks for a month view
  List<List<DateTime>> _getWeeksInMonth(DateTime month) {
    final List<List<DateTime>> weeks = [];
    
    // Find the first day of the month
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    
    // Find which day of the week it is (1 = Monday, 7 = Sunday)
    int weekday = firstDayOfMonth.weekday;
    
    // Calculate the first day to show (Monday of the first week)
    final firstDayToShow = firstDayOfMonth.subtract(
      Duration(days: weekday - 1),
    );
    
    // Generate 6 weeks of days
    DateTime currentDay = firstDayToShow;
    for (int week = 0; week < 6; week++) {
      final List<DateTime> weekDays = [];
      for (int day = 0; day < 7; day++) {
        weekDays.add(currentDay);
        currentDay = currentDay.add(const Duration(days: 1));
      }
      weeks.add(weekDays);
    }
    
    return weeks;
  }
}