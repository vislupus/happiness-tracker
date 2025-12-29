/// Main application configuration
/// All app-wide settings are controlled from here
class AppConfig {
  // App Info
  static const String appName = 'Happiness Tracker';
  static const String appVersion = '1.0.0';
  
  // Happiness Settings
  static const double happinessMinValue = 1.0;
  static const double happinessMaxValue = 10.0;
  static const double happinessStep = 0.5;
  static const double happinessDefaultValue = 5.0;
  
  // Calendar Settings
  static const int weekStartDay = 1; // 1 = Monday, 7 = Sunday
  static const int visibleWeeksInCalendar = 6;
  
  // Animation Durations (milliseconds)
  static const int pageTransitionDuration = 300;
  static const int sliderAnimationDuration = 200;
  static const int colorTransitionDuration = 300;
  
  // Database
  static const String databaseName = 'happiness_tracker.db';
  static const int databaseVersion = 2; // Increased version for migration
  
  // Slider Settings
  static const int sliderDivisions = 18; // (10-1) / 0.5 = 18
  
  // Tags Settings
  static const int maxRecentTags = 10;
  static const int maxTagLength = 30;
  
  // Events Settings
  static const int maxEventColors = 20;
  static const int maxEventDotsPerDay = 3;
}