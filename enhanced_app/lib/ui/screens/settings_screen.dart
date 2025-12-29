import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/database_helper.dart';
import '../../data/providers/subject_provider.dart';
import '../../data/providers/timetable_provider.dart';
import '../../data/providers/study_log_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../utils/time_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Schedule Configuration Section
            _buildSectionHeader(context, 'Schedule Configuration', Icons.access_time),
            
            _buildSliderTile(
              context,
              title: 'Periods Per Day',
              subtitle: '${settingsProvider.periodsPerDay} periods',
              value: settingsProvider.periodsPerDay.toDouble(),
              min: 4,
              max: 12,
              divisions: 8,
              onChanged: (value) => settingsProvider.updatePeriodsPerDay(value.toInt()),
            ),

            _buildSliderTile(
              context,
              title: 'Study Hours Per Day',
              subtitle: '${settingsProvider.studyHoursPerDay} hours',
              value: settingsProvider.studyHoursPerDay.toDouble(),
              min: 2,
              max: 12,
              divisions: 10,
              onChanged: (value) => settingsProvider.updateStudyHoursPerDay(value.toInt()),
            ),

            _buildSliderTile(
              context,
              title: 'Period Duration',
              subtitle: '${settingsProvider.periodDurationMinutes} minutes',
              value: settingsProvider.periodDurationMinutes.toDouble(),
              min: 30,
              max: 90,
              divisions: 12,
              onChanged: (value) => settingsProvider.updatePeriodDuration(value.toInt()),
            ),

            _buildSliderTile(
              context,
              title: 'Break Duration',
              subtitle: '${settingsProvider.breakDurationMinutes} minutes',
              value: settingsProvider.breakDurationMinutes.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              onChanged: (value) => settingsProvider.updateBreakDuration(value.toInt()),
            ),

            const SizedBox(height: 8),

            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Day Start Time'),
              subtitle: Text(settingsProvider.dayStartTime),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectStartTime(context, settingsProvider),
            ),

            const Divider(height: 32),

            // Available Study Time Section
            _buildSectionHeader(context, 'Available Study Time', Icons.timelapse),

            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Available From'),
              subtitle: Text(settingsProvider.availableTimeStart),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectAvailableTimeStart(context, settingsProvider),
            ),

            ListTile(
              leading: const Icon(Icons.stop),
              title: const Text('Available Until'),
              subtitle: Text(settingsProvider.availableTimeEnd),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectAvailableTimeEnd(context, settingsProvider),
            ),

            const SizedBox(height: 8),

            // Info Card
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'How it works:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• "Day Start Time" = When periods begin (affects time display only)',
                      style: TextStyle(fontSize: 11, color: Colors.blue[800]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• "Available Time" = When you can actually study (filters periods)',
                      style: TextStyle(fontSize: 11, color: Colors.blue[800]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 Only periods within Available Time will be scheduled!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Regenerate timetable after changing these settings.',
                      style: TextStyle(fontSize: 10, color: Colors.blue[700], fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 32),

            // Rest Days Section
            _buildSectionHeader(context, 'Rest Days', Icons.weekend),

            _buildRestDaysSelector(context, settingsProvider),

            const Divider(height: 32),

            // Data Management Section
            _buildSectionHeader(context, 'Data Management', Icons.storage),

            Consumer3<SubjectProvider, TimetableProvider, StudyLogProvider>(
              builder: (context, subjectProv, timetableProv, logProv, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDataStat('Subjects', subjectProv.subjects.length),
                        const SizedBox(height: 8),
                        _buildDataStat('Timetable Slots', timetableProv.slots.length),
                        const SizedBox(height: 8),
                        _buildDataStat('Study Logs', logProv.totalLogs),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => _clearAllData(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Clear All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const Divider(height: 32),

            // App Info Section
            _buildSectionHeader(context, 'About', Icons.info),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'StudySync',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Version 2.0.0 (Enhanced)'),
                    SizedBox(height: 4),
                    Text('100% Offline • No Data Collection'),
                    SizedBox(height: 8),
                    Text(
                      'Features:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('✓ Daily & Weekly schedule views'),
                    Text('✓ Real-time slot display'),
                    Text('✓ Quick edit timetable slots'),
                    Text('✓ Configurable study hours'),
                    Text('✓ Available time management'),
                    Text('✓ Priority-based scheduling'),
                    Text('✓ Study session tracking'),
                    Text('✓ Comprehensive statistics'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Offline Status'),
                      content: const Text(
                        '✈️ This app operates 100% offline.\n\n'
                        '• No internet permission\n'
                        '• All data stored locally\n'
                        '• No analytics or tracking\n'
                        '• Your data never leaves your device',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.airplanemode_active),
                label: const Text('100% Offline Mode'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestDaysSelector(BuildContext context, SettingsProvider provider) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            final isSelected = provider.restDays.contains(index);
            return FilterChip(
              label: Text(days[index]),
              selected: isSelected,
              onSelected: (selected) {
                final newRestDays = List<int>.from(provider.restDays);
                if (selected) {
                  newRestDays.add(index);
                } else {
                  newRestDays.remove(index);
                }
                provider.updateRestDays(newRestDays);
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDataStat(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          count.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartTime(BuildContext context, SettingsProvider provider) async {
    final currentHour = TimeUtils.parseHour(provider.dayStartTime);
    final currentMinute = TimeUtils.parseMinute(provider.dayStartTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );

    if (picked != null && context.mounted) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await provider.updateDayStartTime(timeString);
      
      // Show info about regenerating timetable
      if (context.mounted) {
        _showRegenerateInfo(context, 'Day start time updated. Regenerate timetable to apply new times.');
      }
    }
  }

  Future<void> _selectAvailableTimeStart(BuildContext context, SettingsProvider provider) async {
    final currentHour = TimeUtils.parseHour(provider.availableTimeStart);
    final currentMinute = TimeUtils.parseMinute(provider.availableTimeStart);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );

    if (picked != null && context.mounted) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await provider.updateAvailableTimeStart(timeString);
      
      if (context.mounted) {
        _showRegenerateInfo(context, 'Available time updated. Regenerate timetable to apply constraints.');
      }
    }
  }

  Future<void> _selectAvailableTimeEnd(BuildContext context, SettingsProvider provider) async {
    final currentHour = TimeUtils.parseHour(provider.availableTimeEnd);
    final currentMinute = TimeUtils.parseMinute(provider.availableTimeEnd);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );

    if (picked != null && context.mounted) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await provider.updateAvailableTimeEnd(timeString);
      
      if (context.mounted) {
        _showRegenerateInfo(context, 'Available time updated. Regenerate timetable to apply constraints.');
      }
    }
  }

  void _showRegenerateInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Go to Timetable',
          textColor: Colors.white,
          onPressed: () {
            // User can navigate to timetable tab to regenerate
          },
        ),
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all subjects, timetable slots, and study logs. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await DatabaseHelper.instance.deleteDatabase();
        
        // Reload all providers
        if (context.mounted) {
          await context.read<SubjectProvider>().loadSubjects();
          await context.read<TimetableProvider>().loadTimetable();
          await context.read<StudyLogProvider>().loadLogs();
          await context.read<SettingsProvider>().loadSettings();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All data cleared successfully'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
