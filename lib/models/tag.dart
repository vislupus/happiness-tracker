/// Model representing a tag that can be attached to days
class Tag {
  final int? id;
  final String name;
  final DateTime createdAt;
  final int usageCount;
  final double? averageHappiness;

  Tag({
    this.id,
    required this.name,
    DateTime? createdAt,
    this.usageCount = 0,
    this.averageHappiness,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a copy with updated values
  Tag copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? usageCount,
    double? averageHappiness,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
      averageHappiness: averageHappiness ?? this.averageHappiness,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      usageCount: map['usage_count'] as int? ?? 0,
      averageHappiness: map['avg_happiness'] as double?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tag(id: $id, name: $name, usageCount: $usageCount, avgHappiness: $averageHappiness)';
}

/// Model representing the relationship between a day and a tag
class DayTag {
  final int? id;
  final DateTime date;
  final int tagId;
  final DateTime createdAt;

  DayTag({
    this.id,
    required this.date,
    required this.tagId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'tag_id': tagId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DayTag.fromMap(Map<String, dynamic> map) {
    return DayTag(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      tagId: map['tag_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}