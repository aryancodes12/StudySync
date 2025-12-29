import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/study_log_provider.dart';
import '../../data/providers/subject_provider.dart';
import '../../data/providers/timer_provider.dart';
import '../../data/providers/timetable_provider.dart';
import '../../data/models/study_log.dart';
import '../../utils/time_utils.dart';

class StudyLogScreen extends StatelessWidget {
  const StudyLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer4<StudyLogProvider, SubjectProvider, TimerProvider, TimetableProvider>(
      builder: (context, logProvider, subjectProvider, timerProvider, timetableProvider, child) {
        if (logProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show active timer if exists
        if (timerProvider.hasActiveSession) {
          return _buildActiveTimer(context, timerProvider, subjectProvider);
        }

        if (!subjectProvider.hasSubjects) {
          return _buildEmptyState(
            context,
            Icons.book_outlined,
            'No Subjects',
            'Add subjects first to start studying',
          );
        }

        return _buildTimerHome(
          context,
          logProvider,
          subjectProvider,
          timetableProvider,
        );
      },
    );
  }

  Widget _buildActiveTimer(
    BuildContext context,
    TimerProvider timerProvider,
    SubjectProvider subjectProvider,
  ) {
    final session = timerProvider.activeSession!;
    final subject = subjectProvider.getSubjectById(session.subjectId);

    if (subject == null) {
      return const Center(child: Text('Subject not found'));
    }

    final progress = session.progress;
    final isOvertime = progress > 1.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            subject.color.withOpacity(0.3),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'STUDYING',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Timer Display
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 60,
                  color: subject.color,
                ),
                const SizedBox(height: 20),
                Text(
                  session.formattedDuration,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: isOvertime ? Colors.orange : Colors.black87,
                  ),
                ),
                if (timerProvider.isPaused)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PAUSED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Progress Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Started: ${DateFormat('HH:mm').format(session.startTime)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Target: ${session.targetDuration} min',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOvertime ? Colors.orange : subject.color,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  isOvertime
                      ? 'Overtime! Keep going 💪'
                      : '${(progress * 100).toInt()}% complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOvertime ? Colors.orange : Colors.grey[600],
                    fontWeight: isOvertime ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (timerProvider.isPaused) {
                            timerProvider.resumeSession();
                          } else {
                            timerProvider.pauseSession();
                          }
                        },
                        icon: Icon(
                          timerProvider.isPaused ? Icons.play_arrow : Icons.pause,
                        ),
                        label: Text(timerProvider.isPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _endSession(context, timerProvider, subject),
                        icon: const Icon(Icons.stop),
                        label: const Text('End Session'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: subject.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _cancelSession(context, timerProvider),
                  child: Text(
                    'Cancel Session',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerHome(
    BuildContext context,
    StudyLogProvider logProvider,
    SubjectProvider subjectProvider,
    TimetableProvider timetableProvider,
  ) {
    final todaySlots = timetableProvider.getTodaySlots();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Statistics Card
        _buildStatistics(context, logProvider),

        const SizedBox(height: 24),

        // Today's Classes Section
        if (todaySlots.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.today, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Today\'s Classes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...todaySlots.map((slot) {
            final subject = subjectProvider.getSubjectById(slot.subjectId);
            if (subject == null) return const SizedBox.shrink();

            return _buildClassTimerCard(context, slot, subject);
          }),
          const SizedBox(height: 24),
        ],

        // All Subjects Section
        Row(
          children: [
            Icon(Icons.school, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'All Subjects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...subjectProvider.subjects.map((subject) {
          return _buildSubjectTimerCard(context, subject);
        }),

        const SizedBox(height: 24),

        // Recent Sessions
        if (logProvider.hasLogs) ...[
          Row(
            children: [
              Icon(Icons.history, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Recent Sessions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...logProvider.logs.take(5).map((log) {
            final subject = subjectProvider.getSubjectById(log.subjectId);
            if (subject == null) return const SizedBox.shrink();
            return _buildLogCard(context, log, subject);
          }),
        ],
      ],
    );
  }

  Widget _buildClassTimerCard(BuildContext context, slot, subject) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final isNow = slot.startTime != null &&
        currentTime.compareTo(slot.startTime!) >= 0 &&
        currentTime.compareTo(slot.endTime!) < 0;

    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        final hasActiveTimer = timerProvider.hasActiveSession;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isNow ? 4 : 1,
          color: isNow ? subject.color.withOpacity(0.1) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: subject.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            subject.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isNow) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${slot.startTime ?? 'N/A'} - ${slot.endTime ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: hasActiveTimer ? null : () {
                    final duration = slot.endTime != null && slot.startTime != null
                        ? _calculateDuration(slot.startTime!, slot.endTime!)
                        : 60;
                    context.read<TimerProvider>().startSession(subject.id!, duration);
                  },
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasActiveTimer ? Colors.grey : subject.color,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectTimerCard(BuildContext context, subject) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        final hasActiveTimer = timerProvider.hasActiveSession;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: subject.color,
              child: Text(
                subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(subject.name),
            subtitle: Text('Priority: ${subject.priority}'),
            trailing: IconButton(
              icon: Icon(
                Icons.play_circle, 
                color: hasActiveTimer ? Colors.grey : subject.color, 
                size: 32,
              ),
              onPressed: hasActiveTimer ? null : () {
                context.read<TimerProvider>().startSession(subject.id!, 60);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogCard(BuildContext context, StudyLog log, subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: subject.color,
          child: Icon(
            log.wasCompleted ? Icons.check : Icons.close,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(log.sessionStart),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  log.wasCompleted ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: log.wasCompleted ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '${log.completionPercentage.toInt()}%',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${log.focusScore.toStringAsFixed(1)}/5',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '${log.actualDuration}m',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context, StudyLogProvider logProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Study Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.bar_chart,
                  logProvider.totalLogs.toString(),
                  'Sessions',
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.timer,
                  '${logProvider.totalStudyTime.toStringAsFixed(1)}h',
                  'Total Time',
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.check_circle,
                  '${logProvider.averageCompletion.toInt()}%',
                  'Avg Complete',
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSmallStat(
                  logProvider.completedLogs.toString(),
                  'Completed',
                  Colors.green,
                ),
                _buildSmallStat(
                  logProvider.partialLogs.toString(),
                  'Partial',
                  Colors.orange,
                ),
                _buildSmallStat(
                  logProvider.missedLogs.toString(),
                  'Missed',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStat(String value, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: color, size: 8),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String title, String message) {
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
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDuration(String startTime, String endTime) {
    final start = TimeOfDay(
      hour: TimeUtils.parseHour(startTime),
      minute: TimeUtils.parseMinute(startTime),
    );
    final end = TimeOfDay(
      hour: TimeUtils.parseHour(endTime),
      minute: TimeUtils.parseMinute(endTime),
    );
    return (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
  }

  Future<void> _endSession(
    BuildContext context,
    TimerProvider timerProvider,
    subject,
  ) async {
    final session = timerProvider.activeSession;
    
    // GUARD: Validate session exists
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('No active session to save'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EndSessionDialog(
        duration: session.actualDuration,
        subjectName: subject.name,
      ),
    );

    if (result != null && context.mounted) {
      final completedSession = timerProvider.endSession();
      
      // GUARD: Validate completed session
      if (completedSession == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to save session'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // GUARD: Validate duration is reasonable (at least 1 minute)
      if (completedSession.actualDuration < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Session too short to save (< 1 minute)'),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // Now safe to save
      final log = StudyLog(
        subjectId: completedSession.subjectId,
        sessionStart: completedSession.startTime,
        sessionEnd: completedSession.endTime ?? DateTime.now(),
        plannedDuration: completedSession.targetDuration,
        actualDuration: completedSession.actualDuration,
        completionPercentage: result['completion'],
        focusScore: result['focus'],
        difficulty: 3,
        energyLevel: 3,
        productivityScore: result['completion'] / 100.0,
        notes: '',
      );

      await context.read<StudyLogProvider>().createLog(log);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Session saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _cancelSession(BuildContext context, TimerProvider timerProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session?'),
        content: const Text('Your study time will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Studying'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      timerProvider.cancelSession();
    }
  }
}

class _EndSessionDialog extends StatefulWidget {
  final int duration;
  final String subjectName;

  const _EndSessionDialog({
    required this.duration,
    required this.subjectName,
  });

  @override
  State<_EndSessionDialog> createState() => _EndSessionDialogState();
}

class _EndSessionDialogState extends State<_EndSessionDialog> {
  double _completion = 100.0;
  double _focus = 4.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Session Complete!'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    widget.subjectName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Duration: ${widget.duration} minutes',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Completion:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _completion,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: '${_completion.toInt()}%',
                    onChanged: (value) => setState(() => _completion = value),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_completion.toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Focus Level:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _focus,
                    min: 1,
                    max: 5,
                    divisions: 8,
                    label: _focus.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _focus = value),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        _focus.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'completion': _completion,
              'focus': _focus,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
