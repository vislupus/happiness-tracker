import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/happiness_entry.dart';
import '../models/tag.dart';
import '../models/tag_usage.dart';
import '../models/event.dart';
import '../models/event_day.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/chart_data.dart';

/// Sort options for tags
enum TagSortOption {
  happiness,
  usage,
  name,
}

/// Sort options for events
enum EventSortOption {
  date,
  happiness,
  name,
}

/// Main application state provider
class AppProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Current state
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  HappinessEntry? _selectedDayEntry;
  List<Tag> _selectedDayTags = [];
  List<Tag> _allTags = [];
  Map<DateTime, HappinessEntry> _monthEntries = {};
  List<Event> _selectedDayEvents = [];
  List<Event> _monthEvents = [];
  List<Event> _allEvents = [];
  bool _isLoading = false;
  bool _eventsExpanded = true;
  TagSortOption _tagSortOption = TagSortOption.happiness;
  EventSortOption _eventSortOption = EventSortOption.date;

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  HappinessEntry? get selectedDayEntry => _selectedDayEntry;
  List<Tag> get selectedDayTags => _selectedDayTags;
  List<Tag> get allTags => _allTags;
  Map<DateTime, HappinessEntry> get monthEntries => _monthEntries;
  List<Event> get selectedDayEvents => _selectedDayEvents;
  List<Event> get monthEvents => _monthEvents;
  List<Event> get allEvents => _allEvents;
  bool get isLoading => _isLoading;
  bool get eventsExpanded => _eventsExpanded;
  TagSortOption get tagSortOption => _tagSortOption;
  EventSortOption get eventSortOption => _eventSortOption;

  /// Check if a date is today
  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is selected
  bool isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  /// Initialize provider
  Future<void> initialize() async {
    await _loadEventsExpandedState();
    await _loadTagSortOption();
    await _loadEventSortOption();
    await loadAllTags();
    await loadAllEvents();
    await loadMonthData(_currentMonth.year, _currentMonth.month);
    await selectDate(_selectedDate);
  }

  /// Load events expanded state from preferences
  Future<void> _loadEventsExpandedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _eventsExpanded = prefs.getBool('eventsExpanded') ?? true;
    } catch (e) {
      _eventsExpanded = true;
    }
  }

  /// Load tag sort option from preferences
  Future<void> _loadTagSortOption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt('tagSortOption') ?? 0;
      _tagSortOption = TagSortOption.values[index];
    } catch (e) {
      _tagSortOption = TagSortOption.happiness;
    }
  }

  /// Load event sort option from preferences
  Future<void> _loadEventSortOption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt('eventSortOption') ?? 0;
      _eventSortOption = EventSortOption.values[index];
    } catch (e) {
      _eventSortOption = EventSortOption.date;
    }
  }

  /// Toggle events expanded state
  Future<void> toggleEventsExpanded() async {
    _eventsExpanded = !_eventsExpanded;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('eventsExpanded', _eventsExpanded);
    } catch (e) {
      // Ignore preferences errors
    }
  }

  /// Set tag sort option
  Future<void> setTagSortOption(TagSortOption option) async {
    _tagSortOption = option;
    await loadAllTags();
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tagSortOption', option.index);
    } catch (e) {
      // Ignore preferences errors
    }
  }

  /// Set event sort option
  Future<void> setEventSortOption(EventSortOption option) async {
    _eventSortOption = option;
    await loadAllEvents();
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('eventSortOption', option.index);
    } catch (e) {
      // Ignore preferences errors
    }
  }

  /// Select a date
  Future<void> selectDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    await _loadSelectedDayData();
    notifyListeners();
  }

  /// Load data for selected day
  Future<void> _loadSelectedDayData() async {
    _selectedDayEntry = await _db.getHappinessEntry(_selectedDate);
    _selectedDayTags = await _db.getTagsForDay(_selectedDate);
    _selectedDayEvents = await _db.getEventsForDate(_selectedDate);
  }

  /// Change current month
  Future<void> changeMonth(int year, int month) async {
    _currentMonth = DateTime(year, month, 1);
    await loadMonthData(year, month);
    notifyListeners();
  }

  /// Go to previous month
  Future<void> previousMonth() async {
    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    await changeMonth(prevMonth.year, prevMonth.month);
  }

  /// Go to next month
  Future<void> nextMonth() async {
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    await changeMonth(nextMonth.year, nextMonth.month);
  }

  /// Load month data
  Future<void> loadMonthData(int year, int month) async {
    _monthEntries = await _db.getHappinessEntriesForMonth(year, month);
    _monthEvents = await _db.getEventsForMonth(year, month);
  }

  /// Update happiness value
  Future<void> updateHappinessValue({
    double? morning,
    double? afternoon,
    double? evening,
  }) async {
    final currentEntry = _selectedDayEntry ?? HappinessEntry.empty(_selectedDate);
    
    final updatedEntry = currentEntry.copyWith(
      morningValue: morning,
      afternoonValue: afternoon,
      eveningValue: evening,
    );

    await _db.upsertHappinessEntry(updatedEntry);
    
    // Reload data
    _selectedDayEntry = await _db.getHappinessEntry(_selectedDate);
    
    // Update month entries cache
    final dateKey = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    if (_selectedDayEntry != null) {
      _monthEntries[dateKey] = _selectedDayEntry!;
    }
    
    notifyListeners();
  }

  /// Navigate to a specific date (for use from tags/events tab)
  Future<void> navigateToDate(DateTime date) async {
    // Update current month if needed
    if (date.year != _currentMonth.year || date.month != _currentMonth.month) {
      await changeMonth(date.year, date.month);
    }
    // Select the date
    await selectDate(date);
  }

  // ============== TAGS ==============

  /// Load all tags
  Future<void> loadAllTags() async {
    switch (_tagSortOption) {
      case TagSortOption.happiness:
        _allTags = await _db.getAllTagsSortedByHappiness();
        break;
      case TagSortOption.usage:
        _allTags = await _db.getAllTags();
        break;
      case TagSortOption.name:
        _allTags = await _db.getAllTagsSortedByName();
        break;
    }
    notifyListeners();
  }

  /// Create new tag
  Future<Tag?> createTag(String name) async {
    if (name.trim().isEmpty) return null;
    
    // Check if tag already exists
    final existing = await _db.getTagByName(name);
    if (existing != null) return existing;

    await _db.createTag(name);
    await loadAllTags();
    
    return await _db.getTagByName(name);
  }

  /// Update tag name
  Future<void> updateTag(int tagId, String newName) async {
    if (newName.trim().isEmpty) return;
    
    await _db.updateTag(tagId, newName);
    await loadAllTags();
    _selectedDayTags = await _db.getTagsForDay(_selectedDate);
    notifyListeners();
  }

  /// Delete tag
  Future<void> deleteTag(int tagId) async {
    await _db.deleteTag(tagId);
    await loadAllTags();
    _selectedDayTags = await _db.getTagsForDay(_selectedDate);
    notifyListeners();
  }

  /// Merge tags
  Future<void> mergeTags(int sourceTagId, int targetTagId) async {
    await _db.mergeTags(sourceTagId, targetTagId);
    await loadAllTags();
    _selectedDayTags = await _db.getTagsForDay(_selectedDate);
    notifyListeners();
  }

  /// Search tags
  Future<List<Tag>> searchTags(String query) async {
    if (query.trim().isEmpty) {
      return _allTags;
    }
    return await _db.searchTags(query);
  }

  /// Get all days where a tag is used
  Future<List<TagUsageDay>> getTagUsageDays(int tagId) async {
    final maps = await _db.getTagUsageDays(tagId);
    return maps.map((map) => TagUsageDay.fromMap(map)).toList();
  }

  /// Add tag to selected day
  Future<void> addTagToSelectedDay(Tag tag) async {
    await _db.addTagToDay(_selectedDate, tag.id!);
    _selectedDayTags = await _db.getTagsForDay(_selectedDate);
    await loadAllTags(); // Update usage counts
    notifyListeners();
  }

  /// Remove tag from selected day
  Future<void> removeTagFromSelectedDay(Tag tag) async {
    await _db.removeTagFromDay(_selectedDate, tag.id!);
    _selectedDayTags = await _db.getTagsForDay(_selectedDate);
    await loadAllTags(); // Update usage counts
    notifyListeners();
  }

  /// Check if tag is added to selected day
  bool isTagAddedToSelectedDay(Tag tag) {
    return _selectedDayTags.any((t) => t.id == tag.id);
  }

  /// Get happiness entry for a specific date
  HappinessEntry? getEntryForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _monthEntries[dateKey];
  }

  /// Get events for a specific date (from cached month events)
  List<Event> getEventsForDate(DateTime date) {
    return _monthEvents.where((event) => event.occursOnDate(date)).toList();
  }

  // ============== EVENTS ==============

  /// Load all events
  Future<void> loadAllEvents() async {
    switch (_eventSortOption) {
      case EventSortOption.date:
        _allEvents = await _db.getAllEventsWithHappiness();
        break;
      case EventSortOption.happiness:
        _allEvents = await _db.getAllEventsSortedByHappiness();
        break;
      case EventSortOption.name:
        _allEvents = await _db.getAllEventsSortedByName();
        break;
    }
    notifyListeners();
  }

  /// Search events
  Future<List<Event>> searchEventsQuery(String query) async {
    if (query.trim().isEmpty) {
      return _allEvents;
    }
    return await _db.searchEvents(query);
  }

  /// Get all days for an event
  Future<List<EventDay>> getEventDays(int eventId) async {
    final maps = await _db.getEventDays(eventId);
    return maps.map((map) => EventDay.fromMap(map)).toList();
  }

  /// Create new event
  Future<void> createEvent({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int colorIndex,
  }) async {
    final event = Event(
      title: title,
      startDate: startDate,
      endDate: endDate,
      colorIndex: colorIndex,
    );
    
    await _db.createEvent(event);
    await _refreshEvents();
  }

  /// Update event
  Future<void> updateEvent(Event event) async {
    await _db.updateEvent(event);
    await _refreshEvents();
  }

  /// Delete event
  Future<void> deleteEvent(int eventId) async {
    await _db.deleteEvent(eventId);
    await _refreshEvents();
  }

  /// Refresh events data
  Future<void> _refreshEvents() async {
    _monthEvents = await _db.getEventsForMonth(
      _currentMonth.year, 
      _currentMonth.month,
    );
    _selectedDayEvents = await _db.getEventsForDate(_selectedDate);
    await loadAllEvents();
    notifyListeners();
  }

    // ============== CHARTS ==============

  /// Get daily happiness data for a date range
  Future<List<DailyChartData>> getDailyHappinessData(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));
    
    final maps = await _db.getDailyHappinessData(startDate, endDate);
    return maps.map((map) => DailyChartData.fromMap(map)).toList();
  }

  /// Get weekly happiness data
  Future<List<WeeklyChartData>> getWeeklyHappinessData(int weeks) async {
    final maps = await _db.getWeeklyHappinessData(weeks);
    return maps.map((map) => WeeklyChartData.fromMap(map)).toList();
  }

  /// Get monthly happiness data
  Future<List<MonthlyChartData>> getMonthlyHappinessData(int months) async {
    final maps = await _db.getMonthlyHappinessData(months);
    return maps.map((map) => MonthlyChartData.fromMap(map)).toList();
  }

  /// Get yearly happiness data
  Future<List<YearlyChartData>> getYearlyHappinessData() async {
    final maps = await _db.getYearlyHappinessData();
    return maps.map((map) => YearlyChartData.fromMap(map)).toList();
  }

  /// Get overall statistics
  Future<OverallStatistics> getOverallStatistics() async {
    final map = await _db.getOverallStatistics();
    return OverallStatistics.fromMap(map);
  }

  // ============== EXPORT / IMPORT ==============

  /// Export all data to JSON file
  Future<bool> exportData(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = await _db.exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Create filename with date
      final now = DateTime.now();
      final filename = 'happiness_data_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.json';

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile: use share
        final tempDir = await Directory.systemTemp.createTemp();
        final file = File('${tempDir.path}/$filename');
        await file.writeAsString(jsonString);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Happiness Tracker Data Export',
        );
      } else {
        // Desktop: use file picker to save
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Save export file',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        
        if (result != null) {
          final file = File(result);
          await file.writeAsString(jsonString);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Export error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Import data from JSON file
  Future<Map<String, int>?> importData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final importResult = await _db.importData(data);

      // Reload all data
      await loadAllTags();
      await loadAllEvents();
      await loadMonthData(_currentMonth.year, _currentMonth.month);
      await _loadSelectedDayData();

      _isLoading = false;
      notifyListeners();
      return importResult;
    } catch (e) {
      debugPrint('Import error: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}