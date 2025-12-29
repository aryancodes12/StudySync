import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/timetable_slot.dart';
import '../models/subject.dart';
import '../models/app_settings.dart';
import '../../utils/time_utils.dart';

class TimetableProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<TimetableSlot> _slots = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  double _productivityScore = 0.0;

  List<TimetableSlot> get slots => _slots;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  bool get hasTimetable => _slots.isNotEmpty;
  double get productivityScore => _productivityScore;

  // Get slots for specific day (for daily view)
  List<TimetableSlot> getSlotsForDay(int dayOfWeek) {
    return _slots.where((slot) => slot.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.period.compareTo(b.period));
  }

  // Get slots for today
  List<TimetableSlot> getTodaySlots() {
    final today = DateTime.now().weekday % 7; // Convert to 0-6 (Sun=0, Mon=1, ..., Sat=6)
    return getSlotsForDay(today);
  }

  Future<void> loadTimetable() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _slots = await _db.getAllSlots();
      _calculateProductivityScore();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load timetable: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateTimetable(List<Subject> subjects, AppSettings settings) async {
    if (subjects.isEmpty) {
      _error = 'Please add subjects first';
      notifyListeners();
      return false;
    }

    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      // Clear existing timetable
      await _db.clearTimetable();

      // Calculate which periods fit within available time window
      final availablePeriods = _calculateAvailablePeriods(settings);
      
      if (availablePeriods.isEmpty) {
        final periodDuration = settings.periodDurationMinutes;
        final breakDuration = settings.breakDurationMinutes;
        final totalPerPeriod = periodDuration + breakDuration;
        
        _error = 'No periods fit in available time!\n\n'
                 '⏰ Time Window: ${settings.availableTimeStart} - ${settings.availableTimeEnd}\n'
                 '📚 Period + Break: $totalPerPeriod min\n\n'
                 '💡 Solutions:\n'
                 '• Widen time window (e.g., 10:00-14:00)\n'
                 '• Reduce period to 30-40 min\n'
                 '• Reduce break to 5-10 min';
        _isGenerating = false;
        notifyListeners();
        return false;
      }

      // Calculate available days (0=Monday, 6=Sunday)
      final availableDays = <int>[];
      for (int day = 0; day < 7; day++) { // Changed from 5 to 7 to include weekends
        if (!settings.restDays.contains(day)) {
          availableDays.add(day);
        }
      }

      if (availableDays.isEmpty) {
        _error = 'All days are rest days. Please enable at least one study day.';
        _isGenerating = false;
        notifyListeners();
        return false;
      }

      // Calculate total available slots
      final totalSlots = availableDays.length * availablePeriods.length;
      
      // Calculate total periods needed
      int totalPeriodsNeeded = 0;
      for (final subject in subjects) {
        totalPeriodsNeeded += subject.periodsPerWeek;
        if (subject.requiresLab) {
          totalPeriodsNeeded += subject.labPeriodsPerWeek;
        }
      }

      // Check if we have enough slots with buffer for successful scheduling
      if (totalPeriodsNeeded > totalSlots * 0.85) { // Require 15% buffer
        final requiredSlots = (totalPeriodsNeeded / 0.85).ceil();
        final buffer = requiredSlots - totalPeriodsNeeded;
        final hoursNeeded = (requiredSlots * (settings.periodDurationMinutes + settings.breakDurationMinutes) / 60.0).toStringAsFixed(1);
        final hoursAvailable = (totalSlots * (settings.periodDurationMinutes + settings.breakDurationMinutes) / 60.0).toStringAsFixed(1);
        
        _error = '⚠️ Not enough time slots!\n\n'
                 '📊 Current Situation:\n'
                 '• Available: $totalSlots slots ($hoursAvailable hrs)\n'
                 '• Needed: $totalPeriodsNeeded periods\n'
                 '• Required: $requiredSlots slots (with 15% buffer)\n'
                 '• Buffer needed: $buffer slots\n'
                 '• Study days: ${availableDays.length} days\n\n'
                 '⚠️ Need 15% buffer for successful scheduling.\n\n'
                 '💡 Quick Fixes (Pick One):\n'
                 '1. Remove ${((requiredSlots - totalSlots) / availablePeriods.length).ceil()} rest day(s)\n'
                 '2. Reduce ${((requiredSlots - totalSlots) / availableDays.length).ceil()} period(s) per subject\n'
                 '3. Increase periods per day to ${(requiredSlots / availableDays.length).ceil()}\n'
                 '4. Extend study time window';
        _isGenerating = false;
        notifyListeners();
        return false;
      }

      // IMPROVED ALGORITHM: Better distribution and error handling
      
      final newSlots = <TimetableSlot>[];
      
      // Create schedule items list with better organization
      final scheduleItems = <Map<String, dynamic>>[];
      
      for (final subject in subjects) {
        // Add regular periods
        for (int i = 0; i < subject.periodsPerWeek; i++) {
          scheduleItems.add({
            'subject': subject,
            'isLab': false,
            'priority': subject.priority,
          });
        }
        
        // Add lab periods
        if (subject.requiresLab) {
          for (int i = 0; i < subject.labPeriodsPerWeek; i++) {
            scheduleItems.add({
              'subject': subject,
              'isLab': true,
              'priority': subject.priority + 0.5, // Labs slightly higher priority
            });
          }
        }
      }

      // BETTER DISTRIBUTION: Interleave subjects instead of grouping
      // Sort by priority but keep subject variety
      scheduleItems.sort((a, b) {
        final priorityDiff = (b['priority'] as num).compareTo(a['priority'] as num);
        if (priorityDiff != 0) return priorityDiff;
        
        // Same priority - alternate by subject name for variety
        final subjectA = a['subject'] as Subject;
        final subjectB = b['subject'] as Subject;
        return subjectA.name.compareTo(subjectB.name);
      });
      
      // Reorganize to distribute same subjects evenly
      final organizedItems = _distributeEvenly(scheduleItems);

      // Round-robin scheduling with better slot filling
      int slotIndex = 0;
      int scheduledCount = 0;

      for (final item in organizedItems) {
        bool scheduled = false;
        int attempts = 0;
        final maxAttempts = totalSlots * 2; // More attempts for better placement

        while (!scheduled && attempts < maxAttempts) {
          // Calculate day and period for this slot attempt
          final slotNumber = (slotIndex + attempts) % totalSlots;
          final dayIndex = slotNumber ~/ availablePeriods.length;
          final periodIndexInDay = slotNumber % availablePeriods.length;
          
          if (dayIndex >= availableDays.length) {
            attempts++;
            continue;
          }

          final currentDay = availableDays[dayIndex];
          final currentPeriod = availablePeriods[periodIndexInDay];

          // Check if slot is taken
          final slotTaken = newSlots.any((s) => 
            s.dayOfWeek == currentDay && s.period == currentPeriod
          );

          if (!slotTaken) {
            final subject = item['subject'] as Subject;
            final isLab = item['isLab'] as bool;
            
            // Calculate start time based on subject-specific duration
            String startTime;
            String endTime;
            
            // Find previous slots on this day to calculate cumulative time
            final slotsOnThisDay = newSlots.where((s) => s.dayOfWeek == currentDay).toList();
            
            if (slotsOnThisDay.isEmpty) {
              // First slot of the day - use day start time
              startTime = settings.dayStartTime;
            } else {
              // Start after the last slot on this day
              final lastSlot = slotsOnThisDay.last;
              final lastEndTime = lastSlot.endTime ?? settings.getPeriodEndTime(lastSlot.period);
              
              // Find the subject of the last slot to get its break time
              final lastSubjectId = lastSlot.subjectId;
              final lastSubject = subjects.firstWhere((s) => s.id == lastSubjectId);
              
              // Add break time from last subject
              final lastEndParts = TimeUtils.parseTime(lastEndTime);
              final breakMinutes = lastSubject.breakMinutes;
              final totalMinutes = lastEndParts.$1 * 60 + lastEndParts.$2 + breakMinutes;
              startTime = TimeUtils.formatTime(totalMinutes ~/ 60, totalMinutes % 60);
            }
            
            // Calculate end time using this subject's duration
            final startParts = TimeUtils.parseTime(startTime);
            final totalMinutes = startParts.$1 * 60 + startParts.$2 + subject.durationMinutes;
            endTime = TimeUtils.formatTime(totalMinutes ~/ 60, totalMinutes % 60);

            final slot = TimetableSlot(
              subjectId: subject.id!,
              dayOfWeek: currentDay,
              period: currentPeriod,
              isLab: isLab,
              score: _calculateSlotScore(subject, currentPeriod),
              startTime: startTime,
              endTime: endTime,
            );

            newSlots.add(slot);
            scheduled = true;
            scheduledCount++;
            slotIndex++; // Move to next slot for next subject
          }

          attempts++;
        }

        if (!scheduled) {
          _error = 'Could not schedule all periods!\n\n'
                   'Scheduled: $scheduledCount/${scheduleItems.length}\n'
                   'Available slots: $totalSlots\n\n'
                   'Try:\n'
                   '• Increase available time window\n'
                   '• Reduce periods per subject\n'
                   '• Enable more study days';
          _isGenerating = false;
          notifyListeners();
          return false;
        }
      }

      // Save to database
      for (final slot in newSlots) {
        await _db.createSlot(slot);
      }

      await loadTimetable();
      _isGenerating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error generating timetable: $e';
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  // Calculate which periods fit within the available time window
  List<int> _calculateAvailablePeriods(AppSettings settings) {
    final availablePeriods = <int>[];
    
    for (int period = 0; period < settings.periodsPerDay; period++) {
      final startTime = settings.getPeriodStartTime(period);
      final endTime = settings.getPeriodEndTime(period);
      
      // Check if this period fits completely within available window
      final periodStartsInWindow = startTime.compareTo(settings.availableTimeStart) >= 0;
      final periodEndsInWindow = endTime.compareTo(settings.availableTimeEnd) <= 0;
      
      if (periodStartsInWindow && periodEndsInWindow) {
        availablePeriods.add(period);
      }
    }
    
    return availablePeriods;
  }

  // Distribute subjects evenly to avoid grouping same subject together
  List<Map<String, dynamic>> _distributeEvenly(List<Map<String, dynamic>> items) {
    if (items.length <= 1) return items;

    // Group items by subject
    final Map<int, List<Map<String, dynamic>>> subjectGroups = {};
    for (final item in items) {
      final subject = item['subject'] as Subject;
      final subjectId = subject.id!;
      subjectGroups.putIfAbsent(subjectId, () => []);
      subjectGroups[subjectId]!.add(item);
    }

    // Interleave subjects for better distribution
    final distributed = <Map<String, dynamic>>[];
    final subjectLists = subjectGroups.values.toList();
    
    int maxLength = subjectLists.map((list) => list.length).reduce((a, b) => a > b ? a : b);
    
    for (int i = 0; i < maxLength; i++) {
      for (final subjectList in subjectLists) {
        if (i < subjectList.length) {
          distributed.add(subjectList[i]);
        }
      }
    }
    
    return distributed;
  }

  double _calculateSlotScore(Subject subject, int period) {
    double score = subject.priority.toDouble();
    
    // Morning slots (0-3) for difficult subjects
    if (subject.difficulty > 3 && period < 4) {
      score += 2.0;
    }
    
    // Afternoon slots (4-7) for easier subjects
    if (subject.difficulty <= 3 && period >= 4) {
      score += 1.0;
    }
    
    return score;
  }

  void _calculateProductivityScore() {
    if (_slots.isEmpty) {
      _productivityScore = 0.0;
      return;
    }

    double totalScore = 0.0;
    for (final slot in _slots) {
      totalScore += slot.score;
    }
    _productivityScore = totalScore / _slots.length;
  }

  Future<bool> updateSlot(TimetableSlot slot, int newSubjectId) async {
    try {
      final updatedSlot = slot.copyWith(subjectId: newSubjectId);
      await _db.updateSlot(updatedSlot);
      await loadTimetable();
      return true;
    } catch (e) {
      _error = 'Failed to update slot: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearTimetable() async {
    try {
      await _db.clearTimetable();
      await loadTimetable();
      return true;
    } catch (e) {
      _error = 'Failed to clear timetable: $e';
      notifyListeners();
      return false;
    }
  }

  Map<int, List<TimetableSlot>> getSlotsByDay() {
    final slotsByDay = <int, List<TimetableSlot>>{};
    for (int day = 0; day < 7; day++) { // Changed from 5 to 7 to include all days
      slotsByDay[day] = getSlotsForDay(day);
    }
    return slotsByDay;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}