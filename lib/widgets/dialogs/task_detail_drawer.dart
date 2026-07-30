import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../models/reminder_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskDetailDrawer extends StatefulWidget {
  final String taskId;

  const TaskDetailDrawer({super.key, required this.taskId});

  @override
  State<TaskDetailDrawer> createState() => _TaskDetailDrawerState();
}

class _TaskDetailDrawerState extends State<TaskDetailDrawer> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subtaskController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _subtaskController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final taskIndex = taskProvider.tasks.indexWhere((t) => t.id == widget.taskId);
    if (taskIndex == -1) return const SizedBox.shrink();

    final task = taskProvider.tasks[taskIndex];
    if (_titleController.text.isEmpty && _titleController.text != task.title) {
      _titleController.text = task.title;
      _descController.text = task.description ?? '';
    }

    return Container(
      width: isMobile ? double.infinity : 420,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border(left: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(-4, 0)),
        ],
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppTheme.primaryIndigo),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Task Details',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    taskProvider.deleteTask(task.id);
                    navProvider.closeTaskDetailDrawer();
                  },
                  tooltip: 'Delete Task',
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => navProvider.closeTaskDetailDrawer(),
                ),
              ],
            ),
          ),

          // Drawer Form Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title Field
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Task Title',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    taskProvider.updateTask(task.copyWith(title: val));
                  },
                ),

                const SizedBox(height: 12),

                // Status & Priority Selectors
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        initialValue: task.priority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: TaskPriority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(
                              AppTheme.getPriorityLabel(p),
                              style: TextStyle(color: AppTheme.getPriorityColor(p), fontWeight: FontWeight.bold, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) taskProvider.updateTask(task.copyWith(priority: val));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<TaskStatus>(
                        initialValue: task.status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: TaskStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.name.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) taskProvider.updateTaskStatus(task.id, val);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Due Date & Time Slot
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date & Time Scheduling', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 14),
                              label: Text(task.dueDate != null ? DateFormat('MMM d, yyyy').format(task.dueDate!) : 'Set Due Date', style: const TextStyle(fontSize: 12)),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: task.dueDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  taskProvider.updateTask(task.copyWith(dueDate: picked));
                                }
                              },
                            ),
                            const Spacer(),
                            if (task.dueDate != null)
                              TextButton(
                                onPressed: () => taskProvider.updateTask(task.copyWith(dueDate: null)),
                                child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: task.startTime ?? '10:00',
                                decoration: const InputDecoration(labelText: 'Start Time', hintText: '10:00', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (val) => taskProvider.updateTask(task.copyWith(startTime: val)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: task.endTime ?? '11:30',
                                decoration: const InputDecoration(labelText: 'End Time', hintText: '11:30', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (val) => taskProvider.updateTask(task.copyWith(endTime: val)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Alarms & Reminders Engine
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications_active_outlined, size: 16, color: Colors.purple),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text('Alarms & Reminders', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_alert, size: 18, color: AppTheme.primaryIndigo),
                              onPressed: () {
                                final newReminder = ReminderRule(
                                  id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
                                  type: ReminderType.min15Before,
                                  triggerAt: (task.dueDate ?? DateTime.now()).subtract(const Duration(minutes: 15)),
                                );
                                final newReminders = List<ReminderRule>.from(task.reminders)..add(newReminder);
                                taskProvider.updateTask(task.copyWith(reminders: newReminders));
                              },
                              tooltip: 'Add Alarm',
                            ),
                          ],
                        ),
                        if (task.reminders.isEmpty)
                          const Text('No active alarms set', style: TextStyle(fontSize: 11, color: Colors.grey))
                        else
                          ...task.reminders.map(
                            (r) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.alarm, size: 16, color: Colors.purple),
                              title: Text(r.label, style: const TextStyle(fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                                onPressed: () {
                                  final newReminders = task.reminders.where((x) => x.id != r.id).toList();
                                  taskProvider.updateTask(task.copyWith(reminders: newReminders));
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Subtask Checklist Builder
                const Text('Subtasks Checklist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                ...task.checklist.map(
                  (item) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: item.isCompleted,
                    title: Text(item.title, style: TextStyle(fontSize: 13, decoration: item.isCompleted ? TextDecoration.lineThrough : null)),
                    onChanged: (_) => taskProvider.toggleChecklistItem(task.id, item.id),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Add new subtask...', isDense: true),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppTheme.primaryIndigo),
                      onPressed: () {
                        if (_subtaskController.text.trim().isNotEmpty) {
                          taskProvider.addChecklistItem(task.id, _subtaskController.text.trim());
                          _subtaskController.clear();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description Field
                const Text('Description / Notes (Markdown)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Add extra details, code snippets, or notes...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    taskProvider.updateTask(task.copyWith(description: val));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
