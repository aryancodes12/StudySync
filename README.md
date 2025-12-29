# 📚 StudySync - AI-Powered Timetable & Study Tracker

<div align="center">



**Intelligent Timetable Generation | Built-in Study Timer | Offline-First | 100% Free**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://github.com)

[Features](#features) • [Screenshots](#screenshots) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture) • [Contributing](#contributing)

</div>

---

## 🎯 Overview

**StudySync** is a production-ready, offline-first study management app that intelligently generates personalized timetables, tracks study sessions with a built-in timer, and provides detailed analytics—all without requiring an internet connection.

### Why StudySync?

- 🤖 **AI-Powered Scheduling:** Intelligent round-robin algorithm alternates subjects for maximum variety
- ⏰ **Smart Time Management:** Per-subject custom durations (30-180 minutes)
- 📊 **Study Analytics:** Track completion rates, focus scores, and productivity metrics
- 🔒 **100% Offline:** No internet permission, all data stored locally with SQLite
- 🎨 **Clean UI:** Modern Material Design with intuitive navigation
- 🚀 **Production Ready:** Null-safe, crash-resistant, thoroughly tested

---

## ✨ Features

### 🗓️ **Intelligent Timetable Generation**

- **7-Day Full Week Support** - Sunday through Saturday scheduling
- **Subject Alternation** - Round-robin distribution prevents subject grouping
- **Priority & Difficulty Optimization** - Hard subjects scheduled in morning slots
- **Per-Subject Duration** - Each subject can have custom duration (50 min lecture, 120 min lab)
- **Flexible Rest Days** - Configure any day as a rest day
- **Custom Time Windows** - Set your available study hours
- **Automatic Slot Calculation** - Intelligent time slot placement with subject-specific breaks

### ⏱️ **Production-Hardened Study Timer**

- **Subject-Specific Targets** - Each subject uses its own duration as target
- **Pause/Resume Support** - Real-time tracking with pause time excluded
- **Completion Rating** - Self-report completion percentage (0-100%)
- **Focus Score** - Rate your concentration (1-5 stars)
- **Session History** - Complete log of all study sessions
- **Safety Features:**
  - Cannot delete subject with active timer
  - Only one timer session at a time
  - Minimum 1-minute session requirement
  - Null-safe operations throughout

### 📈 **Study Analytics**

- **Completion Statistics** - Track completed, partial, and missed sessions
- **Session Classification:**
  - ✅ **Completed:** 80-100% completion
  - ⚠️ **Partial:** 50-79% completion
  - ❌ **Missed:** 0-49% completion
- **Total Study Time** - Cumulative hours tracked
- **Subject-wise Breakdown** - Time spent per subject
- **Focus Trends** - Average focus scores over time

### 📚 **Subject Management**

- **Flexible Configuration:**
  - Custom duration per subject (30-180 min)
  - Custom break time per subject (0-30 min)
  - Priority levels (1-5)
  - Difficulty ratings (1-5)
  - Lab session support
  - Color coding
- **Smart Validation** - Prevents deletion of subjects with active timers
- **Batch Operations** - Manage multiple subjects efficiently

### ⚙️ **Advanced Settings**

- **7-Day Rest Day Selector** - Mark any days as non-study days
- **Available Time Window** - Define when you're available to study
- **Global Defaults** - Set default period/break durations (overridable per subject)
- **Period Configuration** - Customize periods per day (1-12)
- **Study Hours** - Set total available study hours per day

---

## 📸 Screenshots

<div align="center">

| Weekly Timetable | Daily View | Subject Management |
|------------------|------------|-------------------|
| ![Weekly](/assets/weekly.jpeg) | ![Daily](/assets/daily.jpeg) | ![Subjects](/assets/subjects.jpeg) |

| Study Timer | Analytics | Settings |
|------------|-----------|----------|
| ![Timer](/assets/timer.jpeg) | ![Analytics](/assets/stats.jpeg) | ![Settings](/assets/settings.jpeg) |

</div>

---

## 🚀 Installation

### Prerequisites

- Flutter 3.x or higher
- Dart 3.x or higher
- Android Studio / VS Code
- Android SDK (for Android) or Xcode (for iOS)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/studysync.git
   cd studysync
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build release version**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   ```

---

## 📖 Usage

### First-Time Setup

1. **Add Subjects**
   - Navigate to "Subjects" tab
   - Click ➕ button
   - Configure subject details:
     - Name, duration, priority, difficulty
     - Lab sessions (if applicable)
     - Color for visual identification

2. **Configure Settings**
   - Go to "Settings" tab
   - Set your available study hours
   - Mark rest days (if any)
   - Adjust period/break durations

3. **Generate Timetable**
   - Navigate to "Timetable" tab
   - Click "Generate Timetable"
   - View in Weekly or Daily mode
   - Regenerate anytime for different arrangement

4. **Start Studying**
   - Go to "Study Log" tab
   - Click "Start" on any subject
   - Study with timer tracking
   - End session and rate completion/focus

### Daily Workflow

```
Morning:
1. Check today's timetable (Daily view)
2. Start timer for first subject
3. Study → Pause if needed → End session
4. Rate completion and focus

Throughout Day:
- Follow timetable schedule
- Start timer for each subject
- Track all study sessions

Evening:
- Review study statistics
- Check completed/missed sessions
- Adjust timetable if needed
```

---

## 🏗️ Architecture

### Tech Stack

- **Framework:** Flutter 3.x
- **Language:** Dart 3.x
- **Database:** SQLite (sqflite package)
- **State Management:** Provider pattern
- **Architecture:** Clean Architecture (Presentation → Logic → Data layers)

### Project Structure

```
lib/
├── main.dart                          # App entry point
├── data/
│   ├── database/
│   │   └── database_helper.dart       # SQLite manager
│   ├── models/
│   │   ├── subject.dart               # Subject model
│   │   ├── timetable_slot.dart        # Timetable slot model
│   │   ├── study_log.dart             # Study log model
│   │   ├── study_session.dart         # Active session model
│   │   └── app_settings.dart          # Settings model
│   └── providers/
│       ├── subject_provider.dart      # Subject state management
│       ├── timetable_provider.dart    # Timetable logic
│       ├── study_log_provider.dart    # Study log operations
│       ├── timer_provider.dart        # Timer state
│       └── settings_provider.dart     # Settings persistence
├── ui/
│   └── screens/
│       ├── home_screen.dart           # Main navigation
│       ├── subjects_screen.dart       # Subject list
│       ├── add_subject_screen.dart    # Subject form
│       ├── timetable_screen.dart      # Timetable views
│       ├── study_log_screen.dart      # Timer & history
│       └── settings_screen.dart       # Configuration
└── utils/
    └── time_utils.dart                # Time calculations
```

### Database Schema

#### subjects
```sql
id, name, periodsPerWeek, priority, difficulty, color, 
requiresLab, labPeriodsPerWeek, durationMinutes, breakMinutes, createdAt
```

#### timetable_slots
```sql
id, subjectId, dayOfWeek (0=Sun, 6=Sat), period, isLab, 
score, startTime, endTime
```

#### study_logs
```sql
id, subjectId, startTime, duration, quality, notes, createdAt
```

#### app_settings
```sql
id, periodsPerDay, studyHoursPerDay, dayStartTime, 
periodDurationMinutes, breakDurationMinutes, restDays, 
availableTimeStart, availableTimeEnd
```

---

## 🧠 Core Algorithms

### Timetable Generation Algorithm

**Type:** Intelligent Round-Robin with Even Distribution

```dart
1. Collect all subjects and their periods needed
2. Group subjects by ID
3. Interleave (round-robin):
   - Round 1: Take one from each subject
   - Round 2: Take one from each subject
   - Continue until all periods distributed
4. Place in available time slots:
   - Respect rest days (0-6 encoding)
   - Calculate times using per-subject durations
   - Apply priority/difficulty scoring
   - Alternate subjects for variety
5. Save to database with start/end times
```

**Result:** No subject grouping, maximum variety, optimal timing.

### Study Session Classification

```dart
completionPercentage >= 80.0  → Completed ✅
completionPercentage >= 50.0  → Partial ⚠️
completionPercentage < 50.0   → Missed ❌
```

---

## 🔧 Configuration

### Customization Options

**In `lib/data/models/app_settings.dart`:**
```dart
periodsPerDay: 8,              // Adjust max periods
studyHoursPerDay: 6,          // Total study time
dayStartTime: "08:00",        // When day starts
periodDurationMinutes: 50,    // Default duration
breakDurationMinutes: 10,     // Default break
restDays: [0, 6],            // Sunday, Saturday
availableTimeStart: "08:00",  // Study window start
availableTimeEnd: "20:00"     // Study window end
```

**Per-Subject Overrides:**
```dart
subject.durationMinutes: 120,  // 2-hour lab
subject.breakMinutes: 15       // Longer break
```

---

## 🐛 Known Issues & Fixes

### Issue 1: Timetable Generation Fails with Multiple Rest Days
**Status:** ✅ Fixed  
**Solution:** Added 15% buffer requirement for successful scheduling

### Issue 2: Saturday/Sunday Not Showing in Daily View
**Status:** ✅ Fixed  
**Solution:** Corrected day index conversion (ISO 8601 to 0-6 encoding)

### Issue 3: Friday/Saturday Slots Not Appearing in Weekly View
**Status:** ✅ Fixed  
**Solution:** Extended `getSlotsByDay()` loop from 5 to 7 days

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open a Pull Request**

### Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/studysync.git

# Add upstream remote
git remote add upstream https://github.com/originaluser/studysync.git

# Create branch
git checkout -b feature/YourFeature

# Make changes, then:
flutter analyze
flutter test

# Commit and push
git commit -m "Your message"
git push origin feature/YourFeature
```

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features
- Ensure `flutter analyze` passes with no errors

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## 📝 Changelog

### Version 1.0.0 (Current)
- ✅ Full 7-day timetable support (Sun-Sat)
- ✅ Per-subject custom durations
- ✅ Production-hardened timer system
- ✅ Complete study analytics
- ✅ Intelligent round-robin scheduling
- ✅ Flexible rest day configuration
- ✅ Offline-first architecture

### Planned Features (v1.1.0)
- 📅 Automatic missed lecture detection
- 🔔 Study reminders/notifications
- 📊 Advanced analytics dashboard
- 📤 Export timetable as PDF/image
- 🌙 Dark mode support
- 🔄 Cloud sync (optional)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 StudySync

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👤 Author

**Your Name**
- GitHub: [@aryancodes12](https://github.com/aryancodes12)
- Email: 9040aryangupta@gmail.com

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- SQLite for reliable local storage
- Provider package for state management
- All contributors and users

---


## ⭐ Support

If you find StudySync helpful, please consider:
- ⭐ Starring this repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 🤝 Contributing code

Your support helps improve StudySync for everyone!

---

<div align="center">

**Made with ❤️ using Flutter**

[Back to Top](#studysync---ai-powered-timetable--study-tracker)

</div>
