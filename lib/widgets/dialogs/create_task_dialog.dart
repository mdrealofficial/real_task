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

  int _currentStep = 0; // 0 = Details, 1 = Schedule & Alarms
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
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 500 ? screenWidth * 0.92 : 440.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header (Zero Overflow)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_task, color: AppTheme.primaryIndigo, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Create Task',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2-Step Compact Wizard Segment Control
              Container(
                height: 38,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBg : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentStep = 0),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentStep == 0
                                ? (isDark ? AppTheme.darkCard : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _currentStep == 0
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 16,
                                  color: _currentStep == 0 ? AppTheme.primaryIndigo : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '1. Details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _currentStep == 0 ? FontWeight.bold : FontWeight.normal,
                                    color: _currentStep == 0
                                        ? (isDark ? Colors.white : AppTheme.darkCard)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _currentStep = 1),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _currentStep == 1
                                ? (isDark ? AppTheme.darkCard : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _currentStep == 1
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.alarm,
                                  size: 16,
                                  color: _currentStep == 1 ? AppTheme.primaryIndigo : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '2. Schedule',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.normal,
                                    color: _currentStep == 1
                                        ? (isDark ? Colors.white : AppTheme.darkCard)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // STEP 1: Task Title, Priority & Description
              if (_currentStep == 0) ...[
                // Title Field
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryIndigo),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),

                const SizedBox(height: 14),

                // Priority Selector (Compact Pill Bar)
                const Text('Priority Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: TaskPriority.values.map((p) {
                    final isSelected = _selectedPriority == p;
                    final pColor = AppTheme.getPriorityColor(p);
                    final shortLabel = _getShortPriorityLabel(p);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () => setState(() => _selectedPriority = p),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? pColor.withValues(alpha: 0.18) : (isDark ? AppTheme.darkBg : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? pColor : Colors.transparent, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                shortLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? pColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // Description Field
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Description or notes (optional)...',
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    prefixIcon: const Icon(Icons.notes, size: 18, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],

              // STEP 2: Date, Time & Alarms
              if (_currentStep == 1) ...[
                // Due Date Selector
                const Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month, size: 16, color: AppTheme.primaryIndigo),
                        label: Text(
                          _selectedDate == null ? 'Set Date' : DateFormat('EEE, MMM d, yyyy').format(_selectedDate!),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _selectedDate = null),
                        tooltip: 'Clear Date',
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Start & End Time Range
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

                const SizedBox(height: 14),

                // Alarms & Reminders Options
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBg : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppTheme.primaryIndigo,
                        title: const Text('15-Min Pre-Reminder Alarm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Alarm 15 mins before start time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        value: _enable15mReminder,
                        onChanged: (val) => setState(() => _enable15mReminder = val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppTheme.primaryIndigo,
                        title: const Text('Exact Start Time Alarm', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Alarm right at start time', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        value: _enableStartTimeReminder,
                        onChanged: (val) => setState(() => _enableStartTimeReminder = val),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Action Bar
              Row(
                children: [
                  if (_currentStep == 1)
                    TextButton.icon(
                      onPressed: () => setState(() => _currentStep = 0),
                      icon: const Icon(Icons.arrow_back, size: 14),
                      label: const Text('Back', style: TextStyle(fontSize: 12)),
                    )
                  else
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),

                  const Spacer(),

                  if (_currentStep == 0)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => setState(() => _currentStep = 1),
                      label: const Text('Next: Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      icon: const Icon(Icons.arrow_forward, size: 14),
                    ),

                  const SizedBox(width: 6),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saveTask,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Save', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.p1:
        return 'P1 (Urgent)';
      case TaskPriority.p2:
        return 'P2 (High)';
      case TaskPriority.p3:
        return 'P3 (Med)';
      case TaskPriority.p4:
        return 'P4 (Low)';
    }
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
    if (title.isEmpty) {
      setState(() => _currentStep = 0);
      return;
    }

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
