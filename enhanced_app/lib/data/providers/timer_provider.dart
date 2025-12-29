import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/study_session.dart';

class TimerProvider extends ChangeNotifier {
  StudySession? _activeSession;
  Timer? _timer;
  DateTime? _pauseStartTime;

  StudySession? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSession != null && _activeSession!.isActive;
  bool get isPaused => _activeSession?.isPaused ?? false;

  void startSession(int subjectId, int targetDurationMinutes) {
    // GUARD: Prevent starting if already active
    if (_activeSession != null && _activeSession!.isActive) {
      // Session already running - ignore request
      return;
    }

    // Defensive cleanup: End any lingering session
    if (_activeSession != null) {
      endSession();
    }

    _activeSession = StudySession(
      subjectId: subjectId,
      startTime: DateTime.now(),
      targetDuration: targetDurationMinutes,
      isActive: true,
    );

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Only notify listeners if session is active and not paused
      if (_activeSession != null && !_activeSession!.isPaused) {
        notifyListeners();
      }
    });
  }

  void pauseSession() {
    // GUARD: Validate session exists and is active
    if (_activeSession == null || !_activeSession!.isActive) {
      return;
    }

    // GUARD: Don't pause if already paused
    if (_activeSession!.isPaused) {
      return;
    }

    _activeSession = _activeSession!.copyWith(isPaused: true);
    _pauseStartTime = DateTime.now();
    _timer?.cancel();
    notifyListeners();
  }

  void resumeSession() {
    // GUARD: Validate state before resuming
    if (_activeSession == null || !_activeSession!.isPaused) {
      return;
    }

    if (_pauseStartTime != null) {
      final pauseDuration = DateTime.now().difference(_pauseStartTime!).inSeconds;
      _activeSession = _activeSession!.copyWith(
        isPaused: false,
        pausedDuration: _activeSession!.pausedDuration + pauseDuration,
      );
      _pauseStartTime = null;
    }

    _startTimer();
    notifyListeners();
  }

  StudySession? endSession() {
    // GUARD: Check if session exists
    if (_activeSession == null) {
      return null;
    }

    // SAFE: Cancel timer first
    _timer?.cancel();
    
    // SAFE: Mark as ended
    _activeSession = _activeSession!.copyWith(
      endTime: DateTime.now(),
      isActive: false,
    );

    final completedSession = _activeSession;
    
    // SAFE: Clear all state
    _activeSession = null;
    _pauseStartTime = null;
    
    notifyListeners();
    
    return completedSession;
  }

  void cancelSession() {
    // SAFE: Cancel timer first
    _timer?.cancel();
    
    // SAFE: Clear all state
    _activeSession = null;
    _pauseStartTime = null;
    
    notifyListeners();
  }

  @override
  void dispose() {
    // SAFE: Cancel timer before dispose
    _timer?.cancel();
    _timer = null;
    
    // SAFE: Clear session state
    _activeSession = null;
    _pauseStartTime = null;
    
    super.dispose();
  }
}
