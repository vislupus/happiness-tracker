import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_strings.dart';
import 'tabs/calendar_tab.dart';
import 'tabs/charts_tab.dart';
import 'tabs/events_tab.dart';
import 'tabs/tags_tab.dart';

/// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  /// Switch to calendar tab (used from other tabs)
  void switchToCalendarTab() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return const CalendarTab();
      case 1:
        return const ChartsTab();
      case 2:
        return const EventsTab();
      case 3:
        return const TagsTab();
      default:
        return const CalendarTab();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.navBarBackground,
        border: const Border(
          top: BorderSide(
            color: AppColors.navBarBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.calendar_month_rounded,
            label: AppStrings.navCalendar,
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.bar_chart_rounded,
            label: AppStrings.navCharts,
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.event_rounded,
            label: AppStrings.navEvents,
            index: 2,
          ),
          _buildNavItem(
            icon: Icons.label_rounded,
            label: AppStrings.navTags,
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected 
        ? AppColors.navBarSelectedItem 
        : AppColors.navBarUnselectedItem;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: AppDimensions.animationFast,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryColor.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppDimensions.bottomNavIconSize,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppDimensions.bottomNavLabelSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}