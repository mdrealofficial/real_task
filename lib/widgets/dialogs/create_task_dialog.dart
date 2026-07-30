import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/task_model.dart';
import '../../models/reminder_model.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';

class CreateTaskDialog extends StatefulWidget {
  final TaskStatus initialStatus;

  const CreateTaskDialog({super.key, this.initialStatus = TaskStatus.todo});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TaskPriority _selectedPriority = TaskPriority.p3;
  bool _enable15mReminder = true;
  bool _enableStartTimeReminder = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Set Time';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_task, color: AppTheme.primaryIndigo, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Create New Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Task Title Input
              TextField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  prefixIcon: const Icon(Icons.title, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 14),

              // Task Description Input
              TextField(
                controller: _descController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Description or notes (optional)',
                  prefixIcon: const Icon(Icons.description_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 18),

              // Date & Time Selection Section
              const Text('Date & Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              Row(
                children: [
                  // Due Date Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryIndigo),
                      label: Text(
                        _selectedDate == null ? 'Set Date' : DateFormat('MMM d, yyyy').format(_selectedDate!),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  if (_selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setState(() => _selectedDate = null),
                      tooltip: 'Clear Date',
                    ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  // Start Time Picker Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _pickTime(isStart: true),
                      icon: const Icon(Icons.access_time, size: 16, color: AppTheme.accentCyan),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(_formatTime(_startTime), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // End Time Picker Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _pickTime(isStart: false),
                      icon: const Icon(Icons.timer_outlined, size: 16, color: Colors.purple),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(_formatTime(_endTime), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Priority Selector
              const Text('Priority Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = _selectedPriority == p;
                  final pColor = AppTheme.getPriorityColor(p);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPriority = p),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? pColor.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isSelected ? pColor : Colors.grey.withValues(alpha: 0.3)),
                          ),
                          child: Center(
                            child: Text(
                              AppTheme.getPriorityLabel(p),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? pColor : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Alarms & Reminders Options
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBg : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('15-Minute Pre-Reminder Alarm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Triggers alarm 15 minutes before task start time', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      value: _enable15mReminder,
                      onChanged: (val) => setState(() => _enable15mReminder = val ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Exact Start Time Alarm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      value: _enableStartTimeReminder,
                      onChanged: (val) => setState(() => _enableStartTimeReminder = val ?? false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saveTask,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Create Task', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final uuid = const Uuid();
    final taskId = uuid.v4();

    // Construct reminders list
    final List<ReminderRule> reminders = [];
    if (_selectedDate != null && _startTime != null) {
      final startDt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      if (_enable15mReminder) {
        reminders.add(ReminderRule(
          id: uuid.v4(),
          triggerAt: startDt.subtract(const Duration(minutes: 15)),
          type: ReminderType.min15Before,
        ));
      }

      if (_enableStartTimeReminder) {
        reminders.add(ReminderRule(
          id: uuid.v4(),
          triggerAt: startDt,
          type: ReminderType.atStart,
        ));
      }
    }

    final newTask = Task(
      id: taskId,
      title: title,
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      priority: _selectedPriority,
      status: widget.initialStatus,
      dueDate: _selectedDate,
      startTime: _startTime != null ? _formatTime(_startTime) : null,
      endTime: _endTime != null ? _formatTime(_endTime) : null,
      reminders: reminders,
    );

    Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
    Navigator.pop(context);
  }
}
