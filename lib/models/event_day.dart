/// Model representing a day within an event with happiness data
class EventDay {
  final DateTime date;
  final double? morningValue;
  final double? afternoonValue;
  final double? eveningValue;
  final double? averageHappiness;

  EventDay({
    required this.date,
    this.morningValue,
    this.afternoonValue,
    this.eveningValue,
    this.averageHappiness,
  });

  /// Check if any happiness value is set
  bool get hasHappinessData =>
      morningValue != null || afternoonValue != null || eveningValue != null;

  /// Create from database map
  factory EventDay.fromMap(Map<String, dynamic> map) {
    return EventDay(
      date: DateTime.parse(map['date'] as String),
      morningValue: map['morning_value'] as double?,
      afternoonValue: map['afternoon_value'] as double?,
      eveningValue: map['evening_value'] as double?,
      averageHappiness: map['avg_happiness'] as double?,
    );
  }

  @override
  String toString() => 'EventDay(date: $date, avgHappiness: $averageHappiness)';
}