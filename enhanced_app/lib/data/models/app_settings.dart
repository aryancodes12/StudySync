import '../../utils/time_utils.dart';

class AppSettings {
  final int id;
  final int periodsPerDay;
  final int studyHoursPerDay;
  final String dayStartTime; // "08:00"
  final int periodDurationMinutes;
  final int breakDurationMinutes;
  final List<int> restDays; // 0=Sunday, 6=Saturday
  final String availableTimeStart; // "14:00"
  final String availableTimeEnd; // "20:00"

  AppSettings({
    this.id = 1,
    this.periodsPerDay = 8,
    this.studyHoursPerDay = 6,
    this.dayStartTime = '08:00',
    this.periodDurationMinutes = 50,
    this.breakDurationMinutes = 10,
    this.restDays = const [],
    this.availableTimeStart = '08:00',
    this.availableTimeEnd = '20:00',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'periodsPerDay': periodsPerDay,
      'studyHoursPerDay': studyHoursPerDay,
      'dayStartTime': dayStartTime,
      'periodDurationMinutes': periodDurationMinutes,
      'breakDurationMinutes': breakDurationMinutes,
      'restDays': restDays.join(','),
      'availableTimeStart': availableTimeStart,
      'availableTimeEnd': availableTimeEnd,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] ?? 1,
      periodsPerDay: map['periodsPerDay'] ?? 8,
      studyHoursPerDay: map['studyHoursPerDay'] ?? 6,
      dayStartTime: map['dayStartTime'] ?? '08:00',
      periodDurationMinutes: map['periodDurationMinutes'] ?? 50,
      breakDurationMinutes: map['breakDurationMinutes'] ?? 10,
      restDays: map['restDays'] != null && map['restDays'].toString().isNotEmpty
          ? map['restDays'].toString().split(',').map((e) => int.parse(e)).toList()
          : [],
      availableTimeStart: map['availableTimeStart'] ?? '08:00',
      availableTimeEnd: map['availableTimeEnd'] ?? '20:00',
    );
  }

  AppSettings copyWith({
    int? periodsPerDay,
    int? studyHoursPerDay,
    String? dayStartTime,
    int? periodDurationMinutes,
    int? breakDurationMinutes,
    List<int>? restDays,
    String? availableTimeStart,
    String? availableTimeEnd,
  }) {
    return AppSettings(
      id: id,
      periodsPerDay: periodsPerDay ?? this.periodsPerDay,
      studyHoursPerDay: studyHoursPerDay ?? this.studyHoursPerDay,
      dayStartTime: dayStartTime ?? this.dayStartTime,
      periodDurationMinutes: periodDurationMinutes ?? this.periodDurationMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      restDays: restDays ?? this.restDays,
      availableTimeStart: availableTimeStart ?? this.availableTimeStart,
      availableTimeEnd: availableTimeEnd ?? this.availableTimeEnd,
    );
  }

  // Calculate actual time for a period
  String getPeriodStartTime(int periodIndex) {
    final startHour = TimeUtils.parseHour(dayStartTime);
    final startMinute = TimeUtils.parseMinute(dayStartTime);
    
    final totalMinutes = startMinute + (periodIndex * (periodDurationMinutes + breakDurationMinutes));
    final finalHour = (startHour + (totalMinutes ~/ 60)) % 24;
    final finalMinute = totalMinutes % 60;
    
    return TimeUtils.formatTime(finalHour, finalMinute);
  }

  String getPeriodEndTime(int periodIndex) {
    final startTime = getPeriodStartTime(periodIndex);
    final startHour = TimeUtils.parseHour(startTime);
    final startMinute = TimeUtils.parseMinute(startTime);
    
    final totalMinutes = startMinute + periodDurationMinutes;
    final finalHour = (startHour + (totalMinutes ~/ 60)) % 24;
    final finalMinute = totalMinutes % 60;
    
    return TimeUtils.formatTime(finalHour, finalMinute);
  }

  String getPeriodTimeRange(int periodIndex) {
    return '${getPeriodStartTime(periodIndex)} - ${getPeriodEndTime(periodIndex)}';
  }
}
