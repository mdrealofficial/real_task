import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
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
  bool _isEditing = false; // View-Only Mode by Default

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

  void _confirmDeleteTask(BuildContext context, TaskProvider taskProvider, NavigationProvider navProvider, String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Delete Task?'),
          ],
        ),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              taskProvider.deleteTask(taskId);
              navProvider.closeTaskDetailDrawer();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                Icon(_isEditing ? Icons.edit : Icons.remove_red_eye, color: AppTheme.primaryIndigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit Task' : 'Task Details',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                // Edit / View Mode Switcher Button
                IconButton(
                  icon: Icon(_isEditing ? Icons.visibility_outlined : Icons.edit_outlined, color: AppTheme.primaryIndigo, size: 20),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                  tooltip: _isEditing ? 'View Mode' : 'Edit Task',
                ),

                // Delete Button with Native Confirmation Dialog
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDeleteTask(context, taskProvider, navProvider, task.id),
                  tooltip: 'Delete Task',
                ),

                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => navProvider.closeTaskDetailDrawer(),
                ),
              ],
            ),
          ),

          // Drawer Form Body (View-Only Mode vs Edit Mode)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_isEditing) ...[
                  // ================= READ-ONLY VIEW MODE =================
                  // Task Title Header
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                      color: task.status == TaskStatus.done ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Status & Priority Badges Row
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.primaryIndigo.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          task.status.name.toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.getPriorityColor(task.priority).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppTheme.getPriorityLabel(task.priority),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.getPriorityColor(task.priority)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Schedule Info Card (Clean Format)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.schedule, size: 16, color: AppTheme.primaryIndigo),
                              SizedBox(width: 6),
                              Text('Schedule & Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.dueDate != null ? DateFormat('MMM d, yyyy').format(task.dueDate!) : 'No Due Date',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          if (task.startTime != null || task.endTime != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Time Slot: ${task.startTime ?? ''} - ${task.endTime ?? ''}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description / Notes Card
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const Text('Description / Notes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBg : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                      ),
                      child: Text(
                        task.description!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Checklist Subtasks Section
                  if (task.checklist.isNotEmpty) ...[
                    const Text('Subtasks Checklist', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    ...task.checklist.map(
                      (item) => CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: item.isCompleted,
                        title: Text(item.title, style: TextStyle(fontSize: 13, decoration: item.isCompleted ? TextDecoration.lineThrough : null)),
                        onChanged: (_) => taskProvider.toggleChecklistItem(task.id, item.id),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Status Change & Activity Log Card
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.history, size: 16, color: AppTheme.accentCyan),
                              SizedBox(width: 6),
                              Text('Status Change & Activity Log', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.circle, size: 8, color: AppTheme.accentEmerald),
                              const SizedBox(width: 6),
                              Text('Status: ${task.status.name.toUpperCase()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last Status Update: ${DateFormat('MMM d, yyyy h:mm a').format(task.updatedAt)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Task Created: ${DateFormat('MMM d, yyyy h:mm a').format(task.createdAt)}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _confirmDeleteTask(context, taskProvider, navProvider, task.id),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryIndigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => setState(() => _isEditing = true),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Task', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // ================= FULL EDIT MODE =================
                  // Title Field
                  const Text('Task Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      taskProvider.updateTask(task.copyWith(title: val));
                    },
                  ),

                  const SizedBox(height: 14),

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

                  // Due Date & Time Slot Picker
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

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => setState(() => _isEditing = false),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Save & Done', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
