/// Model representing an event that spans one or more days
class Event {
  final int? id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? averageHappiness;

  Event({
    this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.averageHappiness,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Check if event occurs on a specific date
  bool occursOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    return !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
  }

  /// Get duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Create a copy with updated values
  Event copyWith({
    int? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? averageHappiness,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      averageHappiness: averageHappiness ?? this.averageHappiness,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'color_index': colorIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      title: map['title'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      colorIndex: map['color_index'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      averageHappiness: map['avg_happiness'] as double?,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, start: $startDate, end: $endDate, avgHappiness: $averageHappiness)';
  }
}