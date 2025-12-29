import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/subject.dart';

class SubjectProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Subject> _subjects = [];
  bool _isLoading = false;
  String? _error;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSubjects => _subjects.isNotEmpty;

  Future<void> loadSubjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subjects = await _db.getAllSubjects();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load subjects: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSubject(Subject subject) async {
    try {
      final created = await _db.createSubject(subject);
      _subjects.add(created);
      _subjects.sort((a, b) => b.priority.compareTo(a.priority));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add subject: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(Subject subject) async {
    try {
      await _db.updateSubject(subject);
      final index = _subjects.indexWhere((s) => s.id == subject.id);
      if (index != -1) {
        _subjects[index] = subject;
        _subjects.sort((a, b) => b.priority.compareTo(a.priority));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update subject: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(int id) async {
    try {
      await _db.deleteSubject(id);
      _subjects.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete subject: $e';
      notifyListeners();
      return false;
    }
  }

  Subject? getSubjectById(int id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      // Subject not found - return null
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
