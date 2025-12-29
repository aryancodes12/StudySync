import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/timetable_provider.dart';
import '../../data/providers/subject_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../../data/models/timetable_slot.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  bool _showWeekly = true;

  @override
  Widget build(BuildContext context) {
    return Consumer3<TimetableProvider, SubjectProvider, SettingsProvider>(
      builder: (context, timetableProvider, subjectProvider, settingsProvider, child) {
        if (timetableProvider.isLoading || settingsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!subjectProvider.hasSubjects) {
          return _buildEmptyState(
            context,
            Icons.book_outlined,
            'No Subjects',
            'Add subjects first to generate a timetable',
          );
        }

        if (!timetableProvider.hasTimetable) {
          return _buildNoTimetableState(
            context,
            subjectProvider,
            timetableProvider,
            settingsProvider,
          );
        }

        return Column(
          children: [
            _buildControlBar(context, timetableProvider, subjectProvider, settingsProvider),
            Expanded(
              child: _showWeekly
                  ? _buildWeeklyView(context, timetableProvider, subjectProvider, settingsProvider)
                  : _buildDailyView(context, timetableProvider, subjectProvider, settingsProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlBar(
    BuildContext context,
    TimetableProvider timetableProvider,
    SubjectProvider subjectProvider,
    SettingsProvider settingsProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // View Toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Weekly'),
                icon: Icon(Icons.view_week, size: 18),
              ),
              ButtonSegment(
                value: false,
                label: Text('Today'),
                icon: Icon(Icons.today, size: 18),
              ),
            ],
            selected: {_showWeekly},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() => _showWeekly = newSelection.first);
            },
          ),
          
          const SizedBox(height: 8),
          
          // Productivity Score
          if (timetableProvider.productivityScore > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Score: ${timetableProvider.productivityScore.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _regenerateTimetable(
                    context,
                    timetableProvider,
                    subjectProvider,
                    settingsProvider,
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerate', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _clearTimetable(context, timetableProvider),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(
    BuildContext context,
    TimetableProvider timetableProvider,
    SubjectProvider subjectProvider,
    SettingsProvider settingsProvider,
  ) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final slotsByDay = timetableProvider.getSlotsByDay();
    final maxPeriods = settingsProvider.periodsPerDay;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              const SizedBox(
                width: 60,
                child: Text(
                  'Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              ...days.map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              )),
            ],
          ),
          
          const Divider(),
          
          // Period Rows
          ...List.generate(maxPeriods, (periodIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Column - FIX ISSUE 1: Show only period label
                  SizedBox(
                    width: 60,
                    child: Text(
                      'P${periodIndex + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  
                  // Day Columns - ALL 7 DAYS
                  ...List.generate(7, (dayIndex) {
                    final slot = slotsByDay[dayIndex]?.firstWhere(
                      (s) => s.period == periodIndex,
                      orElse: () => TimetableSlot(
                        subjectId: -1,
                        dayOfWeek: dayIndex,
                        period: periodIndex,
                      ),
                    );

                    if (slot == null || slot.subjectId == -1) {
                      return Expanded(
                        child: Container(
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text('-', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      );
                    }

                    final subject = subjectProvider.getSubjectById(slot.subjectId);
                    if (subject == null) {
                      return const Expanded(
                        child: SizedBox(
                          height: 70,
                          child: Center(child: Text('-')),
                        ),
                      );
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _editSlot(
                          context,
                          slot,
                          timetableProvider,
                          subjectProvider,
                          settingsProvider,
                        ),
                        child: Container(
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: subject.color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: subject.color, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                subject.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              // Show time if available
                              if (slot.startTime != null && slot.endTime != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '${slot.startTime}-${slot.endTime}',
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.grey[800],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              // Show duration
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  '${subject.durationMinutes}m',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: subject.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (slot.isLab)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'LAB',
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyView(
    BuildContext context,
    TimetableProvider timetableProvider,
    SubjectProvider subjectProvider,
    SettingsProvider settingsProvider,
  ) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    final today = DateTime.now();
    final weekday = today.weekday % 7; // Sunday = 0, Monday = 1, ..., Saturday = 6
    
    // FIX ISSUE 2: Removed weekend exclusion check
    // Daily view now works for ALL days (Monday-Sunday)
    
    // Check if selected day is a rest day
    final isRestDay = settingsProvider.settings.restDays.contains(weekday);
    
    if (isRestDay) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.weekend, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Rest Day',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${days[weekday]} is marked as a rest day',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final todaySlots = timetableProvider.getTodaySlots();
    
    if (todaySlots.isEmpty) {
      return _buildEmptyState(
        context,
        Icons.event_available,
        'No Classes Today',
        'You have a free day!',
      );
    }
    
    return Column(
      children: [
        // Date Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(Icons.today, color: Theme.of(context).primaryColor, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    days[weekday],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${today.day}/${today.month}/${today.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${todaySlots.length} classes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Today's Schedule
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todaySlots.length,
            itemBuilder: (context, index) {
              final slot = todaySlots[index];
              final subject = subjectProvider.getSubjectById(slot.subjectId);
              
              if (subject == null) return const SizedBox.shrink();

              final isCurrentPeriod = _isCurrentPeriod(slot.period, settingsProvider);

              return Card(
                elevation: isCurrentPeriod ? 6 : 2,
                color: isCurrentPeriod ? subject.color.withValues(alpha: 0.2) : null,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isCurrentPeriod
                      ? BorderSide(color: subject.color, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => _editSlot(
                    context,
                    slot,
                    timetableProvider,
                    subjectProvider,
                    settingsProvider,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.startTime ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              slot.endTime ?? '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Divider
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(
                            color: subject.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Subject Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      subject.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isCurrentPeriod)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'NOW',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    slot.isLab ? Icons.science : Icons.book,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    slot.isLab ? 'Lab Session' : 'Lecture',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Duration badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: subject.color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: subject.color.withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 14,
                                          color: subject.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${subject.durationMinutes} min',
                                          style: TextStyle(
                                            color: subject.color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.priority_high,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Priority ${subject.priority}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        Icon(Icons.edit, color: Colors.grey[400], size: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isCurrentPeriod(int period, SettingsProvider settings) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final periodStart = settings.getPeriodStartTime(period);
    final periodEnd = settings.getPeriodEndTime(period);
    
    return currentTime.compareTo(periodStart) >= 0 && 
           currentTime.compareTo(periodEnd) < 0;
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTimetableState(
    BuildContext context,
    SubjectProvider subjectProvider,
    TimetableProvider timetableProvider,
    SettingsProvider settingsProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Timetable Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate an AI-optimized schedule',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: timetableProvider.isGenerating
                  ? null
                  : () => _generateTimetable(
                      context,
                      timetableProvider,
                      subjectProvider,
                      settingsProvider,
                    ),
              icon: timetableProvider.isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                timetableProvider.isGenerating
                    ? 'Generating...'
                    : 'Generate Timetable',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateTimetable(
    BuildContext context,
    TimetableProvider timetableProvider,
    SubjectProvider subjectProvider,
    SettingsProvider settingsProvider,
  ) async {
    final success = await timetableProvider.generateTimetable(
      subjectProvider.subjects,
      settingsProvider.settings,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Timetable generated successfully!'
              : 'Failed to generate timetable',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _regenerateTimetable(
    BuildContext context,
    TimetableProvider timetableProvider,
    SubjectProvider subjectProvider,
    SettingsProvider settingsProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Timetable?'),
        content: const Text('This will create a new schedule. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _generateTimetable(
        context,
        timetableProvider,
        subjectProvider,
        settingsProvider,
      );
    }
  }

  Future<void> _clearTimetable(
    BuildContext context,
    TimetableProvider timetableProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Timetable?'),
        content: const Text('This will delete all scheduled slots.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await timetableProvider.clearTimetable();
    
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timetable cleared'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _editSlot(
    BuildContext context,
    TimetableSlot slot,
    TimetableProvider timetableProvider,
    SubjectProvider subjectProvider,
    SettingsProvider settingsProvider,
  ) async {
    final selectedSubject = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Period ${slot.period + 1} - ${slot.timeRange}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ...subjectProvider.subjects.map((subject) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: subject.color,
                    radius: 16,
                  ),
                  title: Text(subject.name),
                  subtitle: Text('Priority: ${subject.priority}'),
                  onTap: () => Navigator.pop(context, subject.id),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedSubject == null) return;
    if (!context.mounted) return;

    final success = await timetableProvider.updateSlot(
      slot,
      selectedSubject,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Slot updated!' : 'Failed to update slot',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}