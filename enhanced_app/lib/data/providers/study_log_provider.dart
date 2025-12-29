import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/study_log.dart';

class StudyLogProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<StudyLog> _logs = [];
  bool _isLoading = false;
  String? _error;

  List<StudyLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLogs => _logs.isNotEmpty;
  int get totalLogs => _logs.length;

  // Statistics getters
  double get totalStudyTime => totalStudyMinutes / 60.0; // in hours
  double get averageCompletion => averageCompletionRate;
  int get completedLogs => completedSessionsCount;
  int get partialLogs => partialSessionsCount;
  int get missedLogs => missedSessionsCount;

  Future<void> loadLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _logs = await _db.getAllLogs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load logs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLog(StudyLog log) async {
    try {
      final created = await _db.createLog(log);
      _logs.insert(0, created); // Add to beginning (most recent first)
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add log: $e';
      notifyListeners();
      return false;
    }
  }

  // Alias for addLog to match usage in timer screen
  Future<bool> createLog(StudyLog log) async {
    return await addLog(log);
  }

  Future<bool> updateLog(StudyLog log) async {
    try {
      await _db.updateLog(log);
      final index = _logs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _logs[index] = log;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update log: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLog(int id) async {
    try {
      await _db.deleteLog(id);
      _logs.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete log: $e';
      notifyListeners();
      return false;
    }
  }

  List<StudyLog> getLogsBySubject(int subjectId) {
    return _logs.where((log) => log.subjectId == subjectId).toList();
  }

  List<StudyLog> getRecentLogs(int count) {
    return _logs.take(count).toList();
  }

  // Statistics
  double get averageCompletionRate {
    if (_logs.isEmpty) return 0.0;
    final total = _logs.fold<double>(
      0.0,
      (sum, log) => sum + log.completionPercentage,
    );
    return total / _logs.length;
  }

  double get averageFocusScore {
    if (_logs.isEmpty) return 0.0;
    final total = _logs.fold<double>(
      0.0,
      (sum, log) => sum + log.focusScore,
    );
    return total / _logs.length;
  }

  int get totalStudyMinutes {
    return _logs.fold<int>(
      0,
      (sum, log) => sum + log.actualDuration,
    );
  }

  int get completedSessionsCount {
    return _logs.where((log) => log.wasCompleted).length;
  }

  int get partialSessionsCount {
    return _logs.where((log) => log.wasPartial).length;
  }

  int get missedSessionsCount {
    return _logs.where((log) => log.wasMissed).length;
  }

  Map<int, int> getStudyTimeBySubject() {
    final Map<int, int> timeBySubject = {};
    for (final log in _logs) {
      timeBySubject[log.subjectId] = 
          (timeBySubject[log.subjectId] ?? 0) + log.actualDuration;
    }
    return timeBySubject;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
