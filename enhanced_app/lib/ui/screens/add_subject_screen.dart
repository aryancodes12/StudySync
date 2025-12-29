import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/subject.dart';
import '../../data/providers/subject_provider.dart';

class AddSubjectScreen extends StatefulWidget {
  final Subject? subject;

  const AddSubjectScreen({Key? key, this.subject}) : super(key: key);

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  double _periodsPerWeek = 3;
  double _priority = 3;
  double _difficulty = 3;
  double _durationMinutes = 50;
  double _breakMinutes = 10;
  Color _selectedColor = Colors.blue;
  bool _requiresLab = false;
  double _labPeriodsPerWeek = 0;
  bool _isSaving = false;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
      _periodsPerWeek = widget.subject!.periodsPerWeek.toDouble();
      _priority = widget.subject!.priority.toDouble();
      _difficulty = widget.subject!.difficulty.toDouble();
      _durationMinutes = widget.subject!.durationMinutes.toDouble();
      _breakMinutes = widget.subject!.breakMinutes.toDouble();
      _selectedColor = widget.subject!.color;
      _requiresLab = widget.subject!.requiresLab;
      _labPeriodsPerWeek = widget.subject!.labPeriodsPerWeek.toDouble();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subject != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Subject Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                hintText: 'e.g., Mathematics',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Periods Per Week
            Text(
              'Periods per week: ${_periodsPerWeek.toInt()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _periodsPerWeek,
              min: 1,
              max: 10,
              divisions: 9,
              label: _periodsPerWeek.toInt().toString(),
              onChanged: (value) {
                setState(() => _periodsPerWeek = value);
              },
            ),
            const SizedBox(height: 16),

            // Priority
            Text(
              'Priority: ${_getPriorityLabel(_priority.toInt())}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _priority,
              min: 1,
              max: 5,
              divisions: 4,
              label: _getPriorityLabel(_priority.toInt()),
              onChanged: (value) {
                setState(() => _priority = value);
              },
            ),
            const SizedBox(height: 16),

            // Difficulty
            Text(
              'Difficulty: ${_getDifficultyLabel(_difficulty.toInt())}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _difficulty,
              min: 1,
              max: 5,
              divisions: 4,
              label: _getDifficultyLabel(_difficulty.toInt()),
              onChanged: (value) {
                setState(() => _difficulty = value);
              },
            ),
            const SizedBox(height: 24),

            // Lecture Duration
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Lecture Duration: ${_durationMinutes.toInt()} minutes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Slider(
              value: _durationMinutes,
              min: 30,
              max: 180,
              divisions: 15,
              label: '${_durationMinutes.toInt()} min',
              onChanged: (value) {
                setState(() => _durationMinutes = value);
              },
            ),
            Text(
              'How long does each lecture last?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // Break Time
            Row(
              children: [
                const Icon(Icons.coffee, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Break Time: ${_breakMinutes.toInt()} minutes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Slider(
              value: _breakMinutes,
              min: 0,
              max: 30,
              divisions: 6,
              label: '${_breakMinutes.toInt()} min',
              onChanged: (value) {
                setState(() => _breakMinutes = value);
              },
            ),
            Text(
              'Break time after this subject',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // Color Selection
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Lab Switch
            SwitchListTile(
              title: const Text('Requires Lab Sessions'),
              subtitle: const Text('For subjects needing practical work'),
              value: _requiresLab,
              onChanged: (value) {
                setState(() {
                  _requiresLab = value;
                  if (!value) _labPeriodsPerWeek = 0;
                });
              },
            ),

            // Lab Periods (if required)
            if (_requiresLab) ...[
              const SizedBox(height: 16),
              Text(
                'Lab periods per week: ${_labPeriodsPerWeek.toInt()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Slider(
                value: _labPeriodsPerWeek,
                min: 0,
                max: 5,
                divisions: 5,
                label: _labPeriodsPerWeek.toInt().toString(),
                onChanged: (value) {
                  setState(() => _labPeriodsPerWeek = value);
                },
              ),
            ],

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveSubject,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Update Subject' : 'Add Subject'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriorityLabel(int value) {
    switch (value) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Medium';
    }
  }

  String _getDifficultyLabel(int value) {
    switch (value) {
      case 1:
        return 'Very Easy';
      case 2:
        return 'Easy';
      case 3:
        return 'Medium';
      case 4:
        return 'Hard';
      case 5:
        return 'Very Hard';
      default:
        return 'Medium';
    }
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for empty name
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Subject name cannot be empty'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final subject = Subject(
      id: widget.subject?.id,
      name: _nameController.text.trim(),
      periodsPerWeek: _periodsPerWeek.toInt(),
      priority: _priority.toInt(),
      difficulty: _difficulty.toInt(),
      durationMinutes: _durationMinutes.toInt(),
      breakMinutes: _breakMinutes.toInt(),
      color: _selectedColor,
      requiresLab: _requiresLab,
      labPeriodsPerWeek: _labPeriodsPerWeek.toInt(),
    );

    final provider = context.read<SubjectProvider>();
    final bool success;

    if (widget.subject != null) {
      success = await provider.updateSubject(subject);
    } else {
      success = await provider.addSubject(subject);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.subject != null
                    ? 'Subject updated successfully!'
                    : 'Subject added successfully!',
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Failed to save subject'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
