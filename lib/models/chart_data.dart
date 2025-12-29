/// Model for daily chart data point
class DailyChartData {
  final DateTime date;
  final double? avgHappiness;
  final double? morningValue;
  final double? afternoonValue;
  final double? eveningValue;

  DailyChartData({
    required this.date,
    this.avgHappiness,
    this.morningValue,
    this.afternoonValue,
    this.eveningValue,
  });

  factory DailyChartData.fromMap(Map<String, dynamic> map) {
    return DailyChartData(
      date: DateTime.parse(map['date'] as String),
      avgHappiness: map['avg_happiness'] as double?,
      morningValue: map['morning_value'] as double?,
      afternoonValue: map['afternoon_value'] as double?,
      eveningValue: map['evening_value'] as double?,
    );
  }
}

/// Model for weekly chart data point
class WeeklyChartData {
  final DateTime weekStart;
  final double avgHappiness;
  final int daysCount;

  WeeklyChartData({
    required this.weekStart,
    required this.avgHappiness,
    required this.daysCount,
  });

  factory WeeklyChartData.fromMap(Map<String, dynamic> map) {
    return WeeklyChartData(
      weekStart: DateTime.parse(map['week_start'] as String),
      avgHappiness: map['avg_happiness'] as double,
      daysCount: map['days_count'] as int,
    );
  }
}

/// Model for monthly chart data point
class MonthlyChartData {
  final int year;
  final int month;
  final double? avgHappiness;
  final int daysCount;

  MonthlyChartData({
    required this.year,
    required this.month,
    this.avgHappiness,
    required this.daysCount,
  });

  factory MonthlyChartData.fromMap(Map<String, dynamic> map) {
    final monthStr = map['month'] as String; // Format: "2025-01"
    final parts = monthStr.split('-');
    return MonthlyChartData(
      year: int.parse(parts[0]),
      month: int.parse(parts[1]),
      avgHappiness: map['avg_happiness'] as double?,
      daysCount: (map['days_count'] as num).toInt(),
    );
  }
}

/// Model for yearly chart data point
class YearlyChartData {
  final int year;
  final double? avgHappiness;
  final int daysCount;

  YearlyChartData({
    required this.year,
    this.avgHappiness,
    required this.daysCount,
  });

  factory YearlyChartData.fromMap(Map<String, dynamic> map) {
    return YearlyChartData(
      year: int.parse(map['year'] as String),
      avgHappiness: map['avg_happiness'] as double?,
      daysCount: (map['days_count'] as num).toInt(),
    );
  }
}

/// Model for overall statistics
class OverallStatistics {
  final int totalEntries;
  final double? overallAvg;
  final DateTime? firstEntry;
  final DateTime? lastEntry;
  final int tagCount;
  final int eventCount;

  OverallStatistics({
    required this.totalEntries,
    this.overallAvg,
    this.firstEntry,
    this.lastEntry,
    required this.tagCount,
    required this.eventCount,
  });

  factory OverallStatistics.fromMap(Map<String, dynamic> map) {
    return OverallStatistics(
      totalEntries: (map['total_entries'] as num?)?.toInt() ?? 0,
      overallAvg: map['overall_avg'] as double?,
      firstEntry: map['first_entry'] != null 
          ? DateTime.parse(map['first_entry'] as String) 
          : null,
      lastEntry: map['last_entry'] != null 
          ? DateTime.parse(map['last_entry'] as String) 
          : null,
      tagCount: (map['tag_count'] as num?)?.toInt() ?? 0,
      eventCount: (map['event_count'] as num?)?.toInt() ?? 0,
    );
  }
}