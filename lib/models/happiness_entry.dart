/// Model representing a happiness entry for a specific day
class HappinessEntry {
  final int? id;
  final DateTime date;
  final double? morningValue;
  final double? afternoonValue;
  final double? eveningValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  HappinessEntry({
    this.id,
    required this.date,
    this.morningValue,
    this.afternoonValue,
    this.eveningValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate average happiness for the day
  double? get averageHappiness {
    final values = [morningValue, afternoonValue, eveningValue]
        .whereType<double>()
        .toList();
    
    if (values.isEmpty) return null;
    
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Check if any value is set
  bool get hasData =>
      morningValue != null || afternoonValue != null || eveningValue != null;

  /// Create a copy with updated values
  HappinessEntry copyWith({
    int? id,
    DateTime? date,
    double? morningValue,
    double? afternoonValue,
    double? eveningValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearMorning = false,
    bool clearAfternoon = false,
    bool clearEvening = false,
  }) {
    return HappinessEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      morningValue: clearMorning ? null : (morningValue ?? this.morningValue),
      afternoonValue: clearAfternoon ? null : (afternoonValue ?? this.afternoonValue),
      eveningValue: clearEvening ? null : (eveningValue ?? this.eveningValue),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'morning_value': morningValue,
      'afternoon_value': afternoonValue,
      'evening_value': eveningValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory HappinessEntry.fromMap(Map<String, dynamic> map) {
    return HappinessEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      morningValue: map['morning_value'] as double?,
      afternoonValue: map['afternoon_value'] as double?,
      eveningValue: map['evening_value'] as double?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create empty entry for a date
  factory HappinessEntry.empty(DateTime date) {
    return HappinessEntry(
      date: DateTime(date.year, date.month, date.day),
    );
  }

  @override
  String toString() {
    return 'HappinessEntry(date: $date, morning: $morningValue, '
        'afternoon: $afternoonValue, evening: $eveningValue)';
  }
}