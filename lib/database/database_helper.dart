import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/app_config.dart';
import '../models/happiness_entry.dart';
import '../models/tag.dart';
import '../models/event.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB() async {
    String path;

    // Get appropriate database path based on platform
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Desktop platforms - use current directory (project folder)
      final currentDir = Directory.current.path;
      final dbDir = Directory(join(currentDir, 'data'));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      path = join(dbDir.path, AppConfig.databaseName);
      debugPrint('Database path: $path');
    } else {
      // Mobile platforms - use app's database directory
      final dbPath = await getDatabasesPath();
      path = join(dbPath, AppConfig.databaseName);
    }

    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    await _createAllTables(db);
  }

  /// Create all tables
  Future<void> _createAllTables(Database db) async {
    // Happiness entries table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS happiness_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        morning_value REAL,
        afternoon_value REAL,
        evening_value REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tags table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      )
    ''');

    // Day-Tag relationship table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS day_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        tag_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE,
        UNIQUE(date, tag_id)
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        color_index INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_happiness_date ON happiness_entries(date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_day_tags_date ON day_tags(date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_day_tags_tag_id ON day_tags(tag_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_events_dates ON events(start_date, end_date)',
    );
  }

  /// Handle database upgrades
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion');

    // Migration from version 1 to 2: Add events table
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          color_index INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_events_dates ON events(start_date, end_date)',
      );

      debugPrint('Created events table');
    }
  }

  /// Delete and recreate database (for development/testing)
  Future<void> resetDatabase() async {
    final db = await database;

    // Drop all tables
    await db.execute('DROP TABLE IF EXISTS day_tags');
    await db.execute('DROP TABLE IF EXISTS tags');
    await db.execute('DROP TABLE IF EXISTS happiness_entries');
    await db.execute('DROP TABLE IF EXISTS events');

    // Recreate all tables
    await _createAllTables(db);

    debugPrint('Database reset complete');
  }

  // ============== HAPPINESS ENTRIES ==============

  /// Insert or update happiness entry
  Future<int> upsertHappinessEntry(HappinessEntry entry) async {
    final db = await database;
    final dateStr = entry.date.toIso8601String().split('T')[0];

    // Check if entry exists
    final existing = await db.query(
      'happiness_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (existing.isEmpty) {
      return await db.insert('happiness_entries', entry.toMap());
    } else {
      return await db.update(
        'happiness_entries',
        entry.toMap(),
        where: 'date = ?',
        whereArgs: [dateStr],
      );
    }
  }

  /// Get happiness entry for a specific date
  Future<HappinessEntry?> getHappinessEntry(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    final maps = await db.query(
      'happiness_entries',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isEmpty) return null;
    return HappinessEntry.fromMap(maps.first);
  }

  /// Get happiness entries for a date range
  Future<List<HappinessEntry>> getHappinessEntriesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];

    final maps = await db.query(
      'happiness_entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'date ASC',
    );

    return maps.map((map) => HappinessEntry.fromMap(map)).toList();
  }

  /// Get all happiness entries for a month
  Future<Map<DateTime, HappinessEntry>> getHappinessEntriesForMonth(
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final entries = await getHappinessEntriesInRange(startDate, endDate);

    final Map<DateTime, HappinessEntry> result = {};
    for (final entry in entries) {
      final dateKey = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      result[dateKey] = entry;
    }
    return result;
  }

  // ============== TAGS ==============

  /// Create a new tag
  Future<int> createTag(String name) async {
    final db = await database;
    return await db.insert('tags', {
      'name': name.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get all tags with usage count and average happiness
  Future<List<Tag>> getAllTags() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT 
        t.*,
        COUNT(dt.id) as usage_count,
        AVG(
          CASE 
            WHEN he.morning_value IS NOT NULL OR he.afternoon_value IS NOT NULL OR he.evening_value IS NOT NULL
            THEN (COALESCE(he.morning_value, 0) + COALESCE(he.afternoon_value, 0) + COALESCE(he.evening_value, 0)) / 
                 (CASE WHEN he.morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN he.afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN he.evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as avg_happiness
      FROM tags t
      LEFT JOIN day_tags dt ON t.id = dt.tag_id
      LEFT JOIN happiness_entries he ON dt.date = he.date
      GROUP BY t.id
      ORDER BY usage_count DESC, t.name ASC
    ''');

    return maps.map((map) => Tag.fromMap(map)).toList();
  }

  /// Get all tags sorted by average happiness
  /// Get all tags sorted by average happiness
  Future<List<Tag>> getAllTagsSortedByHappiness() async {
    final db = await database;
    final maps = await db.rawQuery('''
    SELECT 
      t.*,
      COUNT(dt.id) as usage_count,
      AVG(
        CASE 
          WHEN he.morning_value IS NOT NULL OR he.afternoon_value IS NOT NULL OR he.evening_value IS NOT NULL
          THEN (COALESCE(he.morning_value, 0) + COALESCE(he.afternoon_value, 0) + COALESCE(he.evening_value, 0)) / 
               (CASE WHEN he.morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                CASE WHEN he.afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                CASE WHEN he.evening_value IS NOT NULL THEN 1 ELSE 0 END)
          ELSE NULL
        END
      ) as avg_happiness
    FROM tags t
    LEFT JOIN day_tags dt ON t.id = dt.tag_id
    LEFT JOIN happiness_entries he ON dt.date = he.date
    GROUP BY t.id
    ORDER BY 
      CASE WHEN avg_happiness IS NULL THEN 1 ELSE 0 END,
      avg_happiness DESC, 
      usage_count DESC, 
      t.name ASC
  ''');

    return maps.map((map) => Tag.fromMap(map)).toList();
  }

  /// Get all tags sorted by name
  Future<List<Tag>> getAllTagsSortedByName() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT 
        t.*,
        COUNT(dt.id) as usage_count,
        AVG(
          CASE 
            WHEN he.morning_value IS NOT NULL OR he.afternoon_value IS NOT NULL OR he.evening_value IS NOT NULL
            THEN (COALESCE(he.morning_value, 0) + COALESCE(he.afternoon_value, 0) + COALESCE(he.evening_value, 0)) / 
                 (CASE WHEN he.morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN he.afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN he.evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as avg_happiness
      FROM tags t
      LEFT JOIN day_tags dt ON t.id = dt.tag_id
      LEFT JOIN happiness_entries he ON dt.date = he.date
      GROUP BY t.id
      ORDER BY t.name ASC
    ''');

    return maps.map((map) => Tag.fromMap(map)).toList();
  }

  /// Get tag by name
  Future<Tag?> getTagByName(String name) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT 
        t.*,
        COUNT(dt.id) as usage_count,
        NULL as avg_happiness
      FROM tags t
      LEFT JOIN day_tags dt ON t.id = dt.tag_id
      WHERE t.name = ?
      GROUP BY t.id
    ''', [name.trim()]);

    if (maps.isEmpty) return null;
    return Tag.fromMap(maps.first);
  }

  /// Get all days where a tag is used, with happiness data
  Future<List<Map<String, dynamic>>> getTagUsageDays(int tagId) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT 
        dt.date,
        he.morning_value,
        he.afternoon_value,
        he.evening_value,
        CASE 
          WHEN he.morning_value IS NOT NULL OR he.afternoon_value IS NOT NULL OR he.evening_value IS NOT NULL
          THEN (COALESCE(he.morning_value, 0) + COALESCE(he.afternoon_value, 0) + COALESCE(he.evening_value, 0)) / 
               (CASE WHEN he.morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                CASE WHEN he.afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                CASE WHEN he.evening_value IS NOT NULL THEN 1 ELSE 0 END)
          ELSE NULL
        END as avg_happiness
      FROM day_tags dt
      LEFT JOIN happiness_entries he ON dt.date = he.date
      WHERE dt.tag_id = ?
      ORDER BY dt.date DESC
    ''',
      [tagId],
    );

    return maps;
  }

  /// Update tag name
  Future<int> updateTag(int tagId, String newName) async {
    final db = await database;
    return await db.update(
      'tags',
      {'name': newName.trim()},
      where: 'id = ?',
      whereArgs: [tagId],
    );
  }

  /// Delete tag
  Future<int> deleteTag(int tagId) async {
    final db = await database;
    // First delete all day_tags associations
    await db.delete('day_tags', where: 'tag_id = ?', whereArgs: [tagId]);
    // Then delete the tag
    return await db.delete('tags', where: 'id = ?', whereArgs: [tagId]);
  }

  /// Merge two tags (move all usages from sourceTag to targetTag, then delete sourceTag)
  Future<void> mergeTags(int sourceTagId, int targetTagId) async {
    final db = await database;

    // Get all day_tags for source tag
    final sourceDayTags = await db.query(
      'day_tags',
      where: 'tag_id = ?',
      whereArgs: [sourceTagId],
    );

    // For each day_tag, try to update to target tag
    // If target tag already exists for that day, just delete the source association
    for (final dayTag in sourceDayTags) {
      final date = dayTag['date'] as String;

      // Check if target tag already exists for this day
      final existing = await db.query(
        'day_tags',
        where: 'date = ? AND tag_id = ?',
        whereArgs: [date, targetTagId],
      );

      if (existing.isEmpty) {
        // Update to target tag
        await db.update(
          'day_tags',
          {'tag_id': targetTagId},
          where: 'id = ?',
          whereArgs: [dayTag['id']],
        );
      } else {
        // Delete source association (target already has this day)
        await db.delete('day_tags', where: 'id = ?', whereArgs: [dayTag['id']]);
      }
    }

    // Delete source tag
    await db.delete('tags', where: 'id = ?', whereArgs: [sourceTagId]);
  }

  /// Search tags by name
  Future<List<Tag>> searchTags(String query) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT 
        t.*,
        COUNT(dt.id) as usage_count,
        AVG(
          CASE 
            WHEN he.morning_value IS NOT NULL OR he.afternoon_value IS NOT NULL OR he.evening_value IS NOT NULL
            THEN (COALESCE(he.morning_value, 0) + COALESCE(he.afternoon_value, 0) + COALESCE(he.evening_value, 0)) / 
                 (CASE WHEN he.morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN he.afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN he.evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as avg_happiness
      FROM tags t
      LEFT JOIN day_tags dt ON t.id = dt.tag_id
      LEFT JOIN happiness_entries he ON dt.date = he.date
      WHERE t.name LIKE ?
      GROUP BY t.id
      ORDER BY usage_count DESC, t.name ASC
    ''',
      ['%${query.trim()}%'],
    );

    return maps.map((map) => Tag.fromMap(map)).toList();
  }

  // ============== DAY-TAG RELATIONSHIPS ==============

  /// Add tag to a day
  Future<int> addTagToDay(DateTime date, int tagId) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    try {
      return await db.insert('day_tags', {
        'date': dateStr,
        'tag_id': tagId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Tag already exists for this day
      return -1;
    }
  }

  /// Remove tag from a day
  Future<int> removeTagFromDay(DateTime date, int tagId) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    return await db.delete(
      'day_tags',
      where: 'date = ? AND tag_id = ?',
      whereArgs: [dateStr, tagId],
    );
  }

  /// Get tags for a specific day
  Future<List<Tag>> getTagsForDay(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    final maps = await db.rawQuery(
      '''
      SELECT t.*, 0 as usage_count, NULL as avg_happiness
      FROM tags t
      INNER JOIN day_tags dt ON t.id = dt.tag_id
      WHERE dt.date = ?
      ORDER BY t.name ASC
    ''',
      [dateStr],
    );

    return maps.map((map) => Tag.fromMap(map)).toList();
  }

  // ============== EVENTS ==============

  /// Create a new event
  Future<int> createEvent(Event event) async {
    final db = await database;
    return await db.insert('events', event.toMap());
  }

  /// Update an event
  Future<int> updateEvent(Event event) async {
    final db = await database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Delete an event
  Future<int> deleteEvent(int eventId) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }

  /// Get events for a specific date (ordered by creation time)
  Future<List<Event>> getEventsForDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    final maps = await db.query(
      'events',
      where: 'start_date <= ? AND end_date >= ?',
      whereArgs: [dateStr, dateStr],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => Event.fromMap(map)).toList();
  }

  /// Get events for a month (for calendar display, ordered by creation time)
  Future<List<Event>> getEventsForMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];

    final maps = await db.query(
      'events',
      where: 'start_date <= ? AND end_date >= ?',
      whereArgs: [endStr, startStr],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => Event.fromMap(map)).toList();
  }

  /// Get all events
  Future<List<Event>> getAllEvents() async {
    final db = await database;
    final maps = await db.query('events', orderBy: 'start_date DESC');

    return maps.map((map) => Event.fromMap(map)).toList();
  }

  /// Get all events with average happiness
  Future<List<Event>> getAllEventsWithHappiness() async {
    final db = await database;

    // First get all events
    final eventMaps = await db.query('events', orderBy: 'start_date DESC');

    List<Event> events = [];

    for (final eventMap in eventMaps) {
      final startDate = eventMap['start_date'] as String;
      final endDate = eventMap['end_date'] as String;

      // Get average happiness for this event's date range
      final happinessResult = await db.rawQuery(
        '''
        SELECT AVG(
          CASE 
            WHEN morning_value IS NOT NULL OR afternoon_value IS NOT NULL OR evening_value IS NOT NULL
            THEN (COALESCE(morning_value, 0) + COALESCE(afternoon_value, 0) + COALESCE(evening_value, 0)) / 
                 (CASE WHEN morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as avg_happiness
        FROM happiness_entries
        WHERE date >= ? AND date <= ?
      ''',
        [startDate, endDate],
      );

      final avgHappiness = happinessResult.first['avg_happiness'] as double?;

      final eventWithHappiness = Map<String, dynamic>.from(eventMap);
      eventWithHappiness['avg_happiness'] = avgHappiness;

      events.add(Event.fromMap(eventWithHappiness));
    }

    return events;
  }

  /// Get all events sorted by average happiness
  Future<List<Event>> getAllEventsSortedByHappiness() async {
    final events = await getAllEventsWithHappiness();
    events.sort((a, b) {
      if (a.averageHappiness == null && b.averageHappiness == null) return 0;
      if (a.averageHappiness == null) return 1;
      if (b.averageHappiness == null) return -1;
      return b.averageHappiness!.compareTo(a.averageHappiness!);
    });
    return events;
  }

  /// Get all events sorted by name
  Future<List<Event>> getAllEventsSortedByName() async {
    final events = await getAllEventsWithHappiness();
    events.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return events;
  }

  /// Search events by title
  Future<List<Event>> searchEvents(String query) async {
    final db = await database;

    final eventMaps = await db.query(
      'events',
      where: 'title LIKE ?',
      whereArgs: ['%${query.trim()}%'],
      orderBy: 'start_date DESC',
    );

    List<Event> events = [];

    for (final eventMap in eventMaps) {
      final startDate = eventMap['start_date'] as String;
      final endDate = eventMap['end_date'] as String;

      final happinessResult = await db.rawQuery(
        '''
        SELECT AVG(
          CASE 
            WHEN morning_value IS NOT NULL OR afternoon_value IS NOT NULL OR evening_value IS NOT NULL
            THEN (COALESCE(morning_value, 0) + COALESCE(afternoon_value, 0) + COALESCE(evening_value, 0)) / 
                 (CASE WHEN morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as avg_happiness
        FROM happiness_entries
        WHERE date >= ? AND date <= ?
      ''',
        [startDate, endDate],
      );

      final avgHappiness = happinessResult.first['avg_happiness'] as double?;

      final eventWithHappiness = Map<String, dynamic>.from(eventMap);
      eventWithHappiness['avg_happiness'] = avgHappiness;

      events.add(Event.fromMap(eventWithHappiness));
    }

    return events;
  }

  /// Get all days for an event with happiness data
  Future<List<Map<String, dynamic>>> getEventDays(int eventId) async {
    final db = await database;

    // First get the event to know the date range
    final eventMaps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (eventMaps.isEmpty) return [];

    final event = eventMaps.first;
    final startDate = DateTime.parse(event['start_date'] as String);
    final endDate = DateTime.parse(event['end_date'] as String);

    // Generate all dates in range
    List<Map<String, dynamic>> days = [];
    DateTime currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      final dateStr = currentDate.toIso8601String().split('T')[0];

      // Get happiness data for this date
      final happinessResult = await db.query(
        'happiness_entries',
        where: 'date = ?',
        whereArgs: [dateStr],
      );

      if (happinessResult.isNotEmpty) {
        final he = happinessResult.first;
        final morning = he['morning_value'] as double?;
        final afternoon = he['afternoon_value'] as double?;
        final evening = he['evening_value'] as double?;

        double? avgHappiness;
        if (morning != null || afternoon != null || evening != null) {
          int count = 0;
          double sum = 0;
          if (morning != null) {
            sum += morning;
            count++;
          }
          if (afternoon != null) {
            sum += afternoon;
            count++;
          }
          if (evening != null) {
            sum += evening;
            count++;
          }
          avgHappiness = sum / count;
        }

        days.add({
          'date': dateStr,
          'morning_value': morning,
          'afternoon_value': afternoon,
          'evening_value': evening,
          'avg_happiness': avgHappiness,
        });
      } else {
        days.add({
          'date': dateStr,
          'morning_value': null,
          'afternoon_value': null,
          'evening_value': null,
          'avg_happiness': null,
        });
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return days;
  }

  // ============== CHARTS DATA ==============

  /// Get daily happiness averages for a date range
  Future<List<Map<String, dynamic>>> getDailyHappinessData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];

    final maps = await db.rawQuery(
      '''
      SELECT 
        date,
        morning_value,
        afternoon_value,
        evening_value,
        CASE 
          WHEN morning_value IS NOT NULL OR afternoon_value IS NOT NULL OR evening_value IS NOT NULL
          THEN (COALESCE(morning_value, 0) + COALESCE(afternoon_value, 0) + COALESCE(evening_value, 0)) / 
               (CASE WHEN morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                CASE WHEN afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                CASE WHEN evening_value IS NOT NULL THEN 1 ELSE 0 END)
          ELSE NULL
        END as avg_happiness
      FROM happiness_entries
      WHERE date >= ? AND date <= ?
      ORDER BY date ASC
    ''',
      [startStr, endStr],
    );

    return maps;
  }

  /// Get weekly happiness averages
  Future<List<Map<String, dynamic>>> getWeeklyHappinessData(int weeks) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: weeks * 7));

    // Get all entries in range
    final entries = await getDailyHappinessData(startDate, endDate);

    // Group by week
    Map<String, List<double>> weeklyData = {};

    for (final entry in entries) {
      if (entry['avg_happiness'] != null) {
        final date = DateTime.parse(entry['date'] as String);
        // Get the Monday of the week
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekKey = weekStart.toIso8601String().split('T')[0];

        weeklyData[weekKey] ??= [];
        weeklyData[weekKey]!.add(entry['avg_happiness'] as double);
      }
    }

    // Calculate averages
    List<Map<String, dynamic>> result = [];
    final sortedKeys = weeklyData.keys.toList()..sort();

    for (final weekKey in sortedKeys) {
      final values = weeklyData[weekKey]!;
      final avg = values.reduce((a, b) => a + b) / values.length;
      result.add({
        'week_start': weekKey,
        'avg_happiness': avg,
        'days_count': values.length,
      });
    }

    return result;
  }

  /// Get monthly happiness averages
  Future<List<Map<String, dynamic>>> getMonthlyHappinessData(int months) async {
    final db = await database;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months + 1, 1);
    final startStr = startDate.toIso8601String().split('T')[0];

    final maps = await db.rawQuery(
      '''
      SELECT 
        strftime('%Y-%m', date) as month,
        AVG(
          CASE 
            WHEN morning_value IS NOT NULL OR afternoon_value IS NOT NULL OR evening_value IS NOT NULL
            THEN (COALESCE(morning_value, 0) + COALESCE(afternoon_value, 0) + COALESCE(evening_value, 0)) / 
                 (CASE WHEN morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as avg_happiness,
        COUNT(*) as days_count
      FROM happiness_entries
      WHERE date >= ?
      GROUP BY strftime('%Y-%m', date)
      ORDER BY month ASC
    ''',
      [startStr],
    );

    return maps;
  }

  /// Get yearly happiness averages
  Future<List<Map<String, dynamic>>> getYearlyHappinessData() async {
    final db = await database;

    final maps = await db.rawQuery('''
      SELECT 
        strftime('%Y', date) as year,
        AVG(
          CASE 
            WHEN morning_value IS NOT NULL OR afternoon_value IS NOT NULL OR evening_value IS NOT NULL
            THEN (COALESCE(morning_value, 0) + COALESCE(afternoon_value, 0) + COALESCE(evening_value, 0)) / 
                 (CASE WHEN morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as avg_happiness,
        COUNT(*) as days_count
      FROM happiness_entries
      GROUP BY strftime('%Y', date)
      ORDER BY year ASC
    ''');

    return maps;
  }

  /// Get overall statistics
  Future<Map<String, dynamic>> getOverallStatistics() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_entries,
        AVG(
          CASE 
            WHEN morning_value IS NOT NULL OR afternoon_value IS NOT NULL OR evening_value IS NOT NULL
            THEN (COALESCE(morning_value, 0) + COALESCE(afternoon_value, 0) + COALESCE(evening_value, 0)) / 
                 (CASE WHEN morning_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN afternoon_value IS NOT NULL THEN 1 ELSE 0 END + 
                  CASE WHEN evening_value IS NOT NULL THEN 1 ELSE 0 END)
            ELSE NULL
          END
        ) as overall_avg,
        MIN(date) as first_entry,
        MAX(date) as last_entry
      FROM happiness_entries
    ''');

    final tagCount = await db.rawQuery('SELECT COUNT(*) as count FROM tags');
    final eventCount = await db.rawQuery(
      'SELECT COUNT(*) as count FROM events',
    );

    return {
      ...result.first,
      'tag_count': tagCount.first['count'],
      'event_count': eventCount.first['count'],
    };
  }

  // ============== EXPORT / IMPORT ==============

  /// Export all data to a Map (for JSON)
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;

    // Get all happiness entries
    final happinessEntries = await db.query(
      'happiness_entries',
      orderBy: 'date ASC',
    );

    // Get all tags
    final tags = await db.query('tags', orderBy: 'id ASC');

    // Get all day_tags
    final dayTags = await db.query('day_tags', orderBy: 'date ASC');

    // Get all events
    final events = await db.query('events', orderBy: 'start_date ASC');

    return {
      'export_date': DateTime.now().toIso8601String(),
      'version': AppConfig.databaseVersion,
      'happiness_entries': happinessEntries,
      'tags': tags,
      'day_tags': dayTags,
      'events': events,
    };
  }

  /// Import data from a Map (from JSON)
  Future<Map<String, int>> importData(Map<String, dynamic> data) async {
    final db = await database;

    int happinessImported = 0;
    int tagsImported = 0;
    int dayTagsImported = 0;
    int eventsImported = 0;

    // Import happiness entries
    if (data['happiness_entries'] != null) {
      for (final entry in data['happiness_entries'] as List) {
        try {
          // Check if entry exists
          final existing = await db.query(
            'happiness_entries',
            where: 'date = ?',
            whereArgs: [entry['date']],
          );

          if (existing.isEmpty) {
            await db.insert('happiness_entries', {
              'date': entry['date'],
              'morning_value': entry['morning_value'],
              'afternoon_value': entry['afternoon_value'],
              'evening_value': entry['evening_value'],
              'created_at':
                  entry['created_at'] ?? DateTime.now().toIso8601String(),
              'updated_at':
                  entry['updated_at'] ?? DateTime.now().toIso8601String(),
            });
            happinessImported++;
          }
        } catch (e) {
          debugPrint('Error importing happiness entry: $e');
        }
      }
    }

    // Import tags (need to track old ID to new ID mapping)
    Map<int, int> tagIdMapping = {};
    if (data['tags'] != null) {
      for (final tag in data['tags'] as List) {
        try {
          final oldId = tag['id'] as int;

          // Check if tag with same name exists
          final existing = await db.query(
            'tags',
            where: 'name = ?',
            whereArgs: [tag['name']],
          );

          if (existing.isEmpty) {
            final newId = await db.insert('tags', {
              'name': tag['name'],
              'created_at':
                  tag['created_at'] ?? DateTime.now().toIso8601String(),
            });
            tagIdMapping[oldId] = newId;
            tagsImported++;
          } else {
            tagIdMapping[oldId] = existing.first['id'] as int;
          }
        } catch (e) {
          debugPrint('Error importing tag: $e');
        }
      }
    }

    // Import day_tags
    if (data['day_tags'] != null) {
      for (final dayTag in data['day_tags'] as List) {
        try {
          final oldTagId = dayTag['tag_id'] as int;
          final newTagId = tagIdMapping[oldTagId];

          if (newTagId != null) {
            // Check if association exists
            final existing = await db.query(
              'day_tags',
              where: 'date = ? AND tag_id = ?',
              whereArgs: [dayTag['date'], newTagId],
            );

            if (existing.isEmpty) {
              await db.insert('day_tags', {
                'date': dayTag['date'],
                'tag_id': newTagId,
                'created_at':
                    dayTag['created_at'] ?? DateTime.now().toIso8601String(),
              });
              dayTagsImported++;
            }
          }
        } catch (e) {
          debugPrint('Error importing day_tag: $e');
        }
      }
    }

    // Import events
    if (data['events'] != null) {
      for (final event in data['events'] as List) {
        try {
          // Check if event with same title and dates exists
          final existing = await db.query(
            'events',
            where: 'title = ? AND start_date = ? AND end_date = ?',
            whereArgs: [event['title'], event['start_date'], event['end_date']],
          );

          if (existing.isEmpty) {
            await db.insert('events', {
              'title': event['title'],
              'start_date': event['start_date'],
              'end_date': event['end_date'],
              'color_index': event['color_index'] ?? 0,
              'created_at':
                  event['created_at'] ?? DateTime.now().toIso8601String(),
              'updated_at':
                  event['updated_at'] ?? DateTime.now().toIso8601String(),
            });
            eventsImported++;
          }
        } catch (e) {
          debugPrint('Error importing event: $e');
        }
      }
    }

    return {
      'happiness_entries': happinessImported,
      'tags': tagsImported,
      'day_tags': dayTagsImported,
      'events': eventsImported,
    };
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
