import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);
    final tasks = taskProvider.filteredTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            const Text('No tasks found in this view', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Create a new task using the + button', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isDone = task.status == TaskStatus.done;
        final priorityColor = AppTheme.getPriorityColor(task.priority);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            key: ValueKey(task.id),
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Priority Strip
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                // Checkbox Toggle
                IconButton(
                  icon: Icon(
                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isDone ? AppTheme.accentEmerald : Colors.grey[400],
                    size: 22,
                  ),
                  onPressed: () => taskProvider.toggleTaskStatus(task.id),
                ),
              ],
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Due Date & Time Slot
                  if (task.dueDate != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          task.startTime != null && task.endTime != null
                              ? '${DateFormat('MMM d').format(task.dueDate!)} (${task.startTime} - ${task.endTime})'
                              : DateFormat('MMM d').format(task.dueDate!),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),

                  // Alarm Indicator
                  if (task.reminders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active_outlined, size: 12, color: Colors.purple),
                          SizedBox(width: 3),
                          Text('Alarm', style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                  // Recurrence Badge
                  if (task.recurrence != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.autorenew, size: 12, color: AppTheme.accentCyan),
                          const SizedBox(width: 3),
                          Text(task.recurrence!.displayLabel, style: const TextStyle(fontSize: 10, color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                  // Tag Chips
                  ...task.tags.map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBorder : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.checklist.isNotEmpty)
                  Text(
                    '${task.completedChecklistCount}/${task.checklist.length}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_note, size: 20),
                  onPressed: () => navProvider.openTaskDetailDrawer(task.id),
                  tooltip: 'Edit Task & Subtasks',
                ),
              ],
            ),
            children: [
              // Expandable Checklist Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark ? AppTheme.darkBg.withValues(alpha: 0.5) : Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      Text(task.description!, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700])),
                      const SizedBox(height: 8),
                    ],

                    const Text('Subtasks Checklist:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),

                    ...task.checklist.map(
                      (item) => CheckboxListTile(
                        dense: true,
                        value: item.isCompleted,
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 12,
                            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        onChanged: (_) => taskProvider.toggleChecklistItem(task.id, item.id),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),

                    // Add Subtask Inline Action
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Add Subtask', style: TextStyle(fontSize: 12)),
                        onPressed: () => _showAddSubtaskDialog(context, task.id),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSubtaskDialog(BuildContext context, String taskId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Subtask', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Subtask title...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                Provider.of<TaskProvider>(context, listen: false).addChecklistItem(taskId, textController.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
