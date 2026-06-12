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
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingM,
            AppDimensions.paddingM,
            AppDimensions.paddingM,
            AppDimensions.paddingS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar widget
              const CalendarWidget(),
              
              const SizedBox(height: AppDimensions.paddingM),

              // Separate daily average section
              const DailyAverageSection(),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Happiness sliders
              const HappinessSliders(),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Events section
              const EventsSection(),
              
              const SizedBox(height: AppDimensions.paddingM),
              
              // Tags section
              const TagsSection(),
              
              const SizedBox(height: AppDimensions.paddingS),
            ],
          ),
        );
      },
    );
  }
}
