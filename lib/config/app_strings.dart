/// All application text strings
/// Modify this file for localization or text changes
class AppStrings {
  // App
  static const String appTitle = 'Happiness Tracker';
  
  // Bottom Navigation
  static const String navCalendar = 'Calendar';
  static const String navCharts = 'Charts';
  static const String navEvents = 'Events';
  static const String navTags = 'Tags';
  
  // Calendar
  static const String today = 'Today';
  static const String noDataForDay = 'No data for this day';
  
  // Weekdays (starting Monday)
  static const List<String> weekdaysShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  
  static const List<String> weekdaysFull = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
    'Friday', 'Saturday', 'Sunday'
  ];
  
  // Months - Full names
  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  // Months - Short names (3 letters)
  static const List<String> monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  
  // Happiness Sliders
  static const String morningHappiness = 'Morning';
  static const String afternoonHappiness = 'Afternoon';
  static const String eveningHappiness = 'Evening';
  static const String happinessLevel = 'Happiness Level';
  
  // Slider Labels
  static const String sliderMorningIcon = '🌅';
  static const String sliderAfternoonIcon = '☀️';
  static const String sliderEveningIcon = '🌙';
  
  // Tags
  static const String tagsTitle = 'Tags';
  static const String addTag = 'Add Tag';
  static const String createNewTag = 'Create new tag';
  static const String tagPlaceholder = 'Enter tag name...';
  static const String recentTags = 'Recent Tags';
  static const String allTags = 'All Tags';
  static const String noTags = 'No tags yet';
  static const String tagAdded = 'Tag added';
  static const String tagRemoved = 'Tag removed';
  static const String editTag = 'Edit Tag';
  static const String deleteTag = 'Delete Tag';
  static const String mergeTags = 'Merge Tags';
  static const String mergeInto = 'Merge into';
  static const String selectTagToMerge = 'Select tag to merge into';
  static const String tagDeleted = 'Tag deleted';
  static const String tagUpdated = 'Tag updated';
  static const String tagsMerged = 'Tags merged';
  static const String usedTimes = 'Used %d times';
  static const String usedOnce = 'Used 1 time';
  static const String neverUsed = 'Never used';
  static const String averageHappiness = 'Avg happiness';
  static const String noHappinessData = 'No data';
  static const String sortByHappiness = 'Sort by happiness';
  static const String sortByUsage = 'Sort by usage';
  static const String sortByName = 'Sort by name';
  static const String sortByDate = 'Sort by date';
  static const String searchTags = 'Search tags...';
  static const String searchEvents = 'Search events...';
  static const String confirmDeleteTag = 'Are you sure you want to delete this tag? It will be removed from all days.';
  static const String confirmMergeTags = 'This will merge "%s" into "%s". All usages will be transferred. This cannot be undone.';
  
  // Events
  static const String eventsTitle = 'Events';
  static const String allEvents = 'All Events';
  static const String addEvent = 'Add Event';
  static const String editEvent = 'Edit Event';
  static const String deleteEvent = 'Delete Event';
  static const String eventPlaceholder = 'Event name...';
  static const String noEvents = 'No events for this day';
  static const String noEventsYet = 'No events yet';
  static const String eventStartDate = 'Start Date';
  static const String eventEndDate = 'End Date';
  static const String selectColor = 'Select Color';
  static const String eventSaved = 'Event saved';
  static const String eventDeleted = 'Event deleted';
  static const String confirmDeleteEvent = 'Are you sure you want to delete this event?';
  static const String daysCount = '%d days';
  static const String oneDay = '1 day';
  static const String daysInEvent = 'Days in this event';
  
  // Charts
  static const String chartsTitle = 'Charts';
  static const String last14Days = 'Last 14 Days';
  static const String last30Days = 'Last 30 Days';
  static const String weeks = 'Weeks';
  static const String monthsLabel = 'Months';
  static const String years = 'Years';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String yearly = 'Yearly';
  static const String noChartData = 'No data to display';
  static const String startTracking = 'Start tracking your happiness!';
  static const String overallAverage = 'Overall Average';
  static const String totalEntries = 'Total Entries';
  static const String statistics = 'Statistics';
  static const String happinessTrend = 'Happiness Trend';
  
  // Export / Import
  static const String exportData = 'Export Data';
  static const String importData = 'Import Data';
  static const String exportSuccess = 'Data exported successfully';
  static const String importSuccess = 'Data imported successfully';
  static const String importError = 'Error importing data';
  static const String exportError = 'Error exporting data';
  static const String selectFile = 'Select JSON file';
  static const String dataManagement = 'Data Management';
  static const String entriesImported = '%d entries imported';
  static const String tagsImported = '%d tags imported';
  static const String eventsImported = '%d events imported';
  
  // Buttons
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String done = 'Done';
  static const String merge = 'Merge';
  
  // Placeholders
  static const String chartsPlaceholder = 'Charts coming soon...';
  static const String tagsManagementPlaceholder = 'Tags management coming soon...';
  
  // Messages
  static const String dataSaved = 'Data saved successfully';
  static const String errorSaving = 'Error saving data';
  
  // Format helpers
  static String getMonthYear(int month, int year) {
    return '${months[month - 1]} $year';
  }
  
  static String formatHappinessValue(double value) {
    return value.toStringAsFixed(1);
  }
  
  /// Format date with short month (e.g., "15 Jan")
  static String formatDate(DateTime date) {
    return '${date.day} ${monthsShort[date.month - 1]}';
  }
  
  /// Format date with full month (e.g., "15 January 2025")
  static String formatDateFull(DateTime date) {
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  /// Format date with short month and year (e.g., "15 Jan 2025")
  static String formatDateShort(DateTime date) {
    return '${date.day} ${monthsShort[date.month - 1]} ${date.year}';
  }
  
  /// Format usage count
  static String formatUsageCount(int count) {
    if (count == 0) return neverUsed;
    if (count == 1) return usedOnce;
    return usedTimes.replaceAll('%d', count.toString());
  }
  
  /// Format days count
  static String formatDaysCount(int count) {
    if (count == 1) return oneDay;
    return daysCount.replaceAll('%d', count.toString());
  }
}