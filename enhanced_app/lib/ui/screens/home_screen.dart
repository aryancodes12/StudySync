import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/subject_provider.dart';
import '../../data/providers/timetable_provider.dart';
import '../../data/providers/study_log_provider.dart';
import '../../data/providers/settings_provider.dart';
import 'timetable_screen.dart';
import 'subjects_screen.dart';
import 'study_log_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load all data on app start
    Future.microtask(() {
      context.read<SettingsProvider>().loadSettings();
      context.read<SubjectProvider>().loadSubjects();
      context.read<TimetableProvider>().loadTimetable();
      context.read<StudyLogProvider>().loadLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudySync'),
        actions: [
          Tooltip(
            message: '100% Offline - No internet required',
            child: IconButton(
              icon: const Icon(Icons.cloud_off),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✈️ This app works 100% offline!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          TimetableScreen(),
          SubjectsScreen(),
          StudyLogScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Study Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
