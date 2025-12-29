class TimetableSlot {
  final int? id;
  final int subjectId;
  final int dayOfWeek; // 0 = Monday, 4 = Friday
  final int period; // 0-7 (8 periods per day)
  final bool isLab;
  final double score;
  final String? startTime; // "08:00"
  final String? endTime; // "09:00"
  final DateTime createdAt;

  TimetableSlot({
    this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.period,
    this.isLab = false,
    this.score = 0.0,
    this.startTime,
    this.endTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TimetableSlot copyWith({
    int? id,
    int? subjectId,
    int? dayOfWeek,
    int? period,
    bool? isLab,
    double? score,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
  }) {
    return TimetableSlot(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      period: period ?? this.period,
      isLab: isLab ?? this.isLab,
      score: score ?? this.score,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'dayOfWeek': dayOfWeek,
      'period': period,
      'isLab': isLab ? 1 : 0,
      'score': score,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TimetableSlot.fromMap(Map<String, dynamic> map) {
    return TimetableSlot(
      id: map['id'] as int?,
      subjectId: map['subjectId'] as int,
      dayOfWeek: map['dayOfWeek'] as int,
      period: map['period'] as int,
      isLab: (map['isLab'] as int) == 1,
      score: (map['score'] as num).toDouble(),
      startTime: map['startTime'] as String?,
      endTime: map['endTime'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return days[dayOfWeek];
  }

  String get timeRange {
    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    }
    // Fallback for old data
    final startHour = 8 + period;
    final endHour = startHour + 1;
    return '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00';
  }

  String get displayTime {
    if (startTime != null) {
      return startTime!;
    }
    final hour = 8 + period;
    return '${hour.toString().padLeft(2, '0')}:00';
  }
}
