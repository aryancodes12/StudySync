// Model for active study session (timer)
class StudySession {
  final int? id;
  final int subjectId;
  final DateTime startTime;
  DateTime? endTime;
  final int targetDuration; // in minutes
  bool isActive;
  bool isPaused;
  int pausedDuration; // total paused time in seconds
  
  StudySession({
    this.id,
    required this.subjectId,
    required this.startTime,
    this.endTime,
    required this.targetDuration,
    this.isActive = true,
    this.isPaused = false,
    this.pausedDuration = 0,
  });

  int get actualDuration {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inMinutes;
    }
    return endTime!.difference(startTime).inMinutes;
  }

  int get elapsedSeconds {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inSeconds - pausedDuration;
    }
    return endTime!.difference(startTime).inSeconds - pausedDuration;
  }

  String get formattedDuration {
    final seconds = elapsedSeconds;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (targetDuration == 0) return 0.0;
    return (actualDuration / targetDuration).clamp(0.0, 1.0);
  }

  StudySession copyWith({
    int? id,
    int? subjectId,
    DateTime? startTime,
    DateTime? endTime,
    int? targetDuration,
    bool? isActive,
    bool? isPaused,
    int? pausedDuration,
  }) {
    return StudySession(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      targetDuration: targetDuration ?? this.targetDuration,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      pausedDuration: pausedDuration ?? this.pausedDuration,
    );
  }
}
