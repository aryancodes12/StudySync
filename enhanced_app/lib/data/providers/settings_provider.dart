import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/app_settings.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  AppSettings _settings = AppSettings();
  bool _isLoading = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  // Convenience getters
  int get periodsPerDay => _settings.periodsPerDay;
  int get studyHoursPerDay => _settings.studyHoursPerDay;
  String get dayStartTime => _settings.dayStartTime;
  int get periodDurationMinutes => _settings.periodDurationMinutes;
  int get breakDurationMinutes => _settings.breakDurationMinutes;
  List<int> get restDays => _settings.restDays;
  String get availableTimeStart => _settings.availableTimeStart;
  String get availableTimeEnd => _settings.availableTimeEnd;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _db.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePeriodsPerDay(int value) async {
    _settings = _settings.copyWith(periodsPerDay: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateStudyHoursPerDay(int value) async {
    _settings = _settings.copyWith(studyHoursPerDay: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateDayStartTime(String value) async {
    _settings = _settings.copyWith(dayStartTime: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updatePeriodDuration(int value) async {
    _settings = _settings.copyWith(periodDurationMinutes: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateBreakDuration(int value) async {
    _settings = _settings.copyWith(breakDurationMinutes: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateRestDays(List<int> value) async {
    _settings = _settings.copyWith(restDays: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAvailableTimeStart(String value) async {
    _settings = _settings.copyWith(availableTimeStart: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAvailableTimeEnd(String value) async {
    _settings = _settings.copyWith(availableTimeEnd: value);
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAllSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _db.updateSettings(_settings);
    notifyListeners();
  }

  String getPeriodTimeRange(int periodIndex) {
    return _settings.getPeriodTimeRange(periodIndex);
  }

  String getPeriodStartTime(int periodIndex) {
    return _settings.getPeriodStartTime(periodIndex);
  }

  String getPeriodEndTime(int periodIndex) {
    return _settings.getPeriodEndTime(periodIndex);
  }
}
