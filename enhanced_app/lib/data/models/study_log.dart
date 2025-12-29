class StudyLog {
  final int? id;
  final int subjectId;
  final DateTime sessionStart;
  final DateTime sessionEnd;
  final int plannedDuration; // minutes
  final int actualDuration; // minutes
  final double completionPercentage; // 0-100
  final double focusScore; // 1-5
  final double productivityScore; // 0-1
  final int difficulty; // 1-5
  final int energyLevel; // 1-5
  final String notes;
  final DateTime createdAt;

  StudyLog({
    this.id,
    required this.subjectId,
    required this.sessionStart,
    required this.sessionEnd,
    required this.plannedDuration,
    required this.actualDuration,
    required this.completionPercentage,
    required this.focusScore,
    this.productivityScore = 0.0,
    required this.difficulty,
    this.energyLevel = 3,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  StudyLog copyWith({
    int? id,
    int? subjectId,
    DateTime? sessionStart,
    DateTime? sessionEnd,
    int? plannedDuration,
    int? actualDuration,
    double? completionPercentage,
    double? focusScore,
    double? productivityScore,
    int? difficulty,
    int? energyLevel,
    String? notes,
    DateTime? createdAt,
  }) {
    return StudyLog(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      sessionStart: sessionStart ?? this.sessionStart,
      sessionEnd: sessionEnd ?? this.sessionEnd,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      focusScore: focusScore ?? this.focusScore,
      productivityScore: productivityScore ?? this.productivityScore,
      difficulty: difficulty ?? this.difficulty,
      energyLevel: energyLevel ?? this.energyLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'sessionStart': sessionStart.toIso8601String(),
      'sessionEnd': sessionEnd.toIso8601String(),
      'plannedDuration': plannedDuration,
      'actualDuration': actualDuration,
      'completionPercentage': completionPercentage,
      'focusScore': focusScore,
      'productivityScore': productivityScore,
      'difficulty': difficulty,
      'energyLevel': energyLevel,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StudyLog.fromMap(Map<String, dynamic> map) {
    return StudyLog(
      id: map['id'] as int?,
      subjectId: map['subjectId'] as int,
      sessionStart: DateTime.parse(map['sessionStart'] as String),
      sessionEnd: DateTime.parse(map['sessionEnd'] as String),
      plannedDuration: map['plannedDuration'] as int,
      actualDuration: map['actualDuration'] as int,
      completionPercentage: (map['completionPercentage'] as num).toDouble(),
      focusScore: (map['focusScore'] as num).toDouble(),
      productivityScore: (map['productivityScore'] as num).toDouble(),
      difficulty: map['difficulty'] as int,
      energyLevel: map['energyLevel'] as int? ?? 3,
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  bool get wasCompleted => completionPercentage >= 80.0;
  bool get wasPartial => completionPercentage >= 50.0 && completionPercentage < 80.0;
  bool get wasMissed => completionPercentage < 50.0;

  String get completionStatus {
    if (wasCompleted) return 'Completed';
    if (wasPartial) return 'Partial';
    return 'Missed';
  }

  String get focusLabel {
    if (focusScore >= 4.5) return 'Excellent';
    if (focusScore >= 3.5) return 'Good';
    if (focusScore >= 2.5) return 'Average';
    if (focusScore >= 1.5) return 'Poor';
    return 'Very Poor';
  }
}
