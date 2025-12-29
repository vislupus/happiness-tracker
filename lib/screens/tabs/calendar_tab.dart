import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_dimensions.dart';
import '../../providers/app_provider.dart';
import '../../widgets/calendar/calendar_widget.dart';
import '../../widgets/happiness_sliders.dart';
import '../../widgets/tags_section.dart';
import '../../widgets/events_section.dart';

/// Calendar tab - main screen for viewing and editing happiness data
class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar widget
              const CalendarWidget(),
              
              const SizedBox(height: AppDimensions.paddingL),
              
              // Happiness sliders (картата е премахната)
              const HappinessSliders(),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Events section
              const EventsSection(),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Tags section
              const TagsSection(),
              
              // Bottom spacing for navigation bar
              const SizedBox(height: AppDimensions.paddingXL),
            ],
          ),
        );
      },
    );
  }
}