import 'package:flutter/material.dart';

class Subject {
  final int? id;
  final String name;
  final int periodsPerWeek;
  final int priority; // 1-5
  final int difficulty; // 1-5
  final Color color;
  final bool requiresLab;
  final int labPeriodsPerWeek;
  final int durationMinutes; // Duration for this subject's lectures
  final int breakMinutes; // Break time after this subject
  final DateTime createdAt;

  Subject({
    this.id,
    required this.name,
    required this.periodsPerWeek,
    required this.priority,
    required this.difficulty,
    Color? color,
    this.requiresLab = false,
    this.labPeriodsPerWeek = 0,
    this.durationMinutes = 50, // Default 50 minutes
    this.breakMinutes = 10, // Default 10 minutes break
    DateTime? createdAt,
  })  : color = color ?? Colors.blue,
        createdAt = createdAt ?? DateTime.now();

  Subject copyWith({
    int? id,
    String? name,
    int? periodsPerWeek,
    int? priority,
    int? difficulty,
    Color? color,
    bool? requiresLab,
    int? labPeriodsPerWeek,
    int? durationMinutes,
    int? breakMinutes,
    DateTime? createdAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      periodsPerWeek: periodsPerWeek ?? this.periodsPerWeek,
      priority: priority ?? this.priority,
      difficulty: difficulty ?? this.difficulty,
      color: color ?? this.color,
      requiresLab: requiresLab ?? this.requiresLab,
      labPeriodsPerWeek: labPeriodsPerWeek ?? this.labPeriodsPerWeek,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'periodsPerWeek': periodsPerWeek,
      'priority': priority,
      'difficulty': difficulty,
      'color': color.value,
      'requiresLab': requiresLab ? 1 : 0,
      'labPeriodsPerWeek': labPeriodsPerWeek,
      'durationMinutes': durationMinutes,
      'breakMinutes': breakMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as int?,
      name: map['name'] as String,
      periodsPerWeek: map['periodsPerWeek'] as int,
      priority: map['priority'] as int,
      difficulty: map['difficulty'] as int,
      color: Color(map['color'] as int),
      requiresLab: (map['requiresLab'] as int) == 1,
      labPeriodsPerWeek: map['labPeriodsPerWeek'] as int? ?? 0,
      durationMinutes: map['durationMinutes'] as int? ?? 50, // Default for old data
      breakMinutes: map['breakMinutes'] as int? ?? 10, // Default for old data
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Very Easy';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
      default:
        return 'Medium';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Medium';
    }
  }
}
