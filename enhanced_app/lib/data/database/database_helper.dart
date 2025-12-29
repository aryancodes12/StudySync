import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subject.dart';
import '../models/timetable_slot.dart';
import '../models/study_log.dart';
import '../models/app_settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('timetable.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increment version for new columns
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop old settings table
      await db.execute('DROP TABLE IF EXISTS settings');
      
      // Add time columns to timetable_slots if not exists
      try {
        await db.execute('ALTER TABLE timetable_slots ADD COLUMN startTime TEXT');
        await db.execute('ALTER TABLE timetable_slots ADD COLUMN endTime TEXT');
      } catch (e) {
        // Columns might already exist
        print('Time columns already exist or error: $e');
      }
      
      // Create new app_settings table
      await db.execute('''
        CREATE TABLE app_settings (
          id INTEGER PRIMARY KEY,
          periodsPerDay INTEGER NOT NULL,
          studyHoursPerDay INTEGER NOT NULL,
          dayStartTime TEXT NOT NULL,
          periodDurationMinutes INTEGER NOT NULL,
          breakDurationMinutes INTEGER NOT NULL,
          restDays TEXT,
          availableTimeStart TEXT NOT NULL,
          availableTimeEnd TEXT NOT NULL
        )
      ''');
      
      // Insert default settings
      await db.insert('app_settings', {
        'id': 1,
        'periodsPerDay': 8,
        'studyHoursPerDay': 6,
        'dayStartTime': '08:00',
        'periodDurationMinutes': 50,
        'breakDurationMinutes': 10,
        'restDays': '',
        'availableTimeStart': '08:00',
        'availableTimeEnd': '20:00',
      });
    }
    
    // Version 3: Add duration fields to subjects
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE subjects ADD COLUMN durationMinutes INTEGER DEFAULT 50');
        await db.execute('ALTER TABLE subjects ADD COLUMN breakMinutes INTEGER DEFAULT 10');
      } catch (e) {
        print('Duration columns already exist or error: $e');
      }
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Subjects table
    await db.execute('''
      CREATE TABLE subjects (
        id $idType,
        name $textType,
        periodsPerWeek $intType,
        priority $intType,
        difficulty $intType,
        color $intType,
        requiresLab INTEGER DEFAULT 0,
        labPeriodsPerWeek INTEGER DEFAULT 0,
        durationMinutes INTEGER DEFAULT 50,
        breakMinutes INTEGER DEFAULT 10,
        createdAt $textType
      )
    ''');

    // Timetable slots table
    await db.execute('''
      CREATE TABLE timetable_slots (
        id $idType,
        subjectId INTEGER NOT NULL,
        dayOfWeek $intType,
        period $intType,
        isLab INTEGER DEFAULT 0,
        score $realType,
        startTime TEXT,
        endTime TEXT,
        createdAt $textType,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    // Study logs table
    await db.execute('''
      CREATE TABLE study_logs (
        id $idType,
        subjectId INTEGER NOT NULL,
        sessionStart $textType,
        sessionEnd $textType,
        plannedDuration INTEGER NOT NULL,
        actualDuration INTEGER NOT NULL,
        completionPercentage $realType,
        focusScore $realType,
        productivityScore $realType,
        difficulty $intType,
        energyLevel $intType,
        notes TEXT,
        createdAt $textType,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');

    // App Settings table (new enhanced version)
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY,
        periodsPerDay INTEGER NOT NULL,
        studyHoursPerDay INTEGER NOT NULL,
        dayStartTime TEXT NOT NULL,
        periodDurationMinutes INTEGER NOT NULL,
        breakDurationMinutes INTEGER NOT NULL,
        restDays TEXT,
        availableTimeStart TEXT NOT NULL,
        availableTimeEnd TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('app_settings', {
      'id': 1,
      'periodsPerDay': 8,
      'studyHoursPerDay': 6,
      'dayStartTime': '08:00',
      'periodDurationMinutes': 50,
      'breakDurationMinutes': 10,
      'restDays': '',
      'availableTimeStart': '08:00',
      'availableTimeEnd': '20:00',
    });
  }

  // ==================== SUBJECTS ====================
  
  Future<Subject> createSubject(Subject subject) async {
    final db = await instance.database;
    final id = await db.insert('subjects', subject.toMap());
    return subject.copyWith(id: id);
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await instance.database;
    const orderBy = 'priority DESC';
    final result = await db.query('subjects', orderBy: orderBy);
    return result.map((json) => Subject.fromMap(json)).toList();
  }

  Future<Subject?> getSubject(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await instance.database;
    return db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await instance.database;
    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== TIMETABLE SLOTS ====================
  
  Future<TimetableSlot> createSlot(TimetableSlot slot) async {
    final db = await instance.database;
    final id = await db.insert('timetable_slots', slot.toMap());
    return slot.copyWith(id: id);
  }

  Future<List<TimetableSlot>> getAllSlots() async {
    final db = await instance.database;
    const orderBy = 'dayOfWeek ASC, period ASC';
    final result = await db.query('timetable_slots', orderBy: orderBy);
    return result.map((json) => TimetableSlot.fromMap(json)).toList();
  }

  Future<List<TimetableSlot>> getSlotsByDay(int dayOfWeek) async {
    final db = await instance.database;
    final result = await db.query(
      'timetable_slots',
      where: 'dayOfWeek = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'period ASC',
    );
    return result.map((json) => TimetableSlot.fromMap(json)).toList();
  }

  Future<int> clearAllSlots() async {
    final db = await instance.database;
    return await db.delete('timetable_slots');
  }

  Future<int> clearTimetable() async {
    return await clearAllSlots();
  }

  Future<int> updateSlot(TimetableSlot slot) async {
    final db = await instance.database;
    return await db.update(
      'timetable_slots',
      slot.toMap(),
      where: 'id = ?',
      whereArgs: [slot.id],
    );
  }

  Future<void> saveTimetable(List<TimetableSlot> slots) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('timetable_slots');
      for (final slot in slots) {
        await txn.insert('timetable_slots', slot.toMap());
      }
    });
  }

  // ==================== STUDY LOGS ====================
  
  Future<StudyLog> createLog(StudyLog log) async {
    final db = await instance.database;
    final id = await db.insert('study_logs', log.toMap());
    return log.copyWith(id: id);
  }

  Future<List<StudyLog>> getAllLogs() async {
    final db = await instance.database;
    const orderBy = 'sessionStart DESC';
    final result = await db.query('study_logs', orderBy: orderBy);
    return result.map((json) => StudyLog.fromMap(json)).toList();
  }

  Future<List<StudyLog>> getLogsBySubject(int subjectId) async {
    final db = await instance.database;
    final result = await db.query(
      'study_logs',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
      orderBy: 'sessionStart DESC',
    );
    return result.map((json) => StudyLog.fromMap(json)).toList();
  }

  Future<List<StudyLog>> getLogsInDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final result = await db.query(
      'study_logs',
      where: 'sessionStart BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'sessionStart DESC',
    );
    return result.map((json) => StudyLog.fromMap(json)).toList();
  }

  Future<int> updateLog(StudyLog log) async {
    final db = await instance.database;
    return db.update(
      'study_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteLog(int id) async {
    final db = await instance.database;
    return await db.delete(
      'study_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== SETTINGS ====================
  
  Future<String?> getSetting(String key) async {
    final db = await instance.database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== APP SETTINGS ====================

  Future<AppSettings> getSettings() async {
    final db = await instance.database;
    final result = await db.query('app_settings', where: 'id = ?', whereArgs: [1]);
    
    if (result.isNotEmpty) {
      return AppSettings.fromMap(result.first);
    }
    
    // Return default if not found
    return AppSettings();
  }

  Future<int> updateSettings(AppSettings settings) async {
    final db = await instance.database;
    return db.update(
      'app_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ==================== UTILITY ====================
  
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timetable.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
