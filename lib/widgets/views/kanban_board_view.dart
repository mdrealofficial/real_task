import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import '../dialogs/create_task_dialog.dart';
import 'package:intl/intl.dart';

class KanbanBoardView extends StatelessWidget {
  const KanbanBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.filteredTasks;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<TaskStatus, List<Task>> columns = {
      TaskStatus.backlog: tasks.where((t) => t.status == TaskStatus.backlog).toList(),
      TaskStatus.todo: tasks.where((t) => t.status == TaskStatus.todo).toList(),
      TaskStatus.inProgress: tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
      TaskStatus.done: tasks.where((t) => t.status == TaskStatus.done).toList(),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          // Mobile Tabbed Column View (Full Vertical View Height)
          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Container(
                  color: isDark ? AppTheme.darkCard : Colors.grey[100],
                  child: const TabBar(
                    isScrollable: true,
                    labelColor: AppTheme.primaryIndigo,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Backlog'),
                      Tab(text: 'To Do'),
                      Tab(text: 'In Progress'),
                      Tab(text: 'Done'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildKanbanColumn(context, 'Backlog', TaskStatus.backlog, columns[TaskStatus.backlog]!, isMobile: true),
                      _buildKanbanColumn(context, 'To Do', TaskStatus.todo, columns[TaskStatus.todo]!, isMobile: true),
                      _buildKanbanColumn(context, 'In Progress', TaskStatus.inProgress, columns[TaskStatus.inProgress]!, isMobile: true),
                      _buildKanbanColumn(context, 'Done', TaskStatus.done, columns[TaskStatus.done]!, isMobile: true),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Desktop / Tablet Multi-Column Side-by-Side View (Full View Height & Scrollable Columns)
        return SizedBox(
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: constraints.maxHeight - 32,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildKanbanColumn(context, 'Backlog', TaskStatus.backlog, columns[TaskStatus.backlog]!, isMobile: false),
                  _buildKanbanColumn(context, 'To Do', TaskStatus.todo, columns[TaskStatus.todo]!, isMobile: false),
                  _buildKanbanColumn(context, 'In Progress', TaskStatus.inProgress, columns[TaskStatus.inProgress]!, isMobile: false),
                  _buildKanbanColumn(context, 'Done', TaskStatus.done, columns[TaskStatus.done]!, isMobile: false),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    String title,
    TaskStatus status,
    List<Task> columnTasks, {
    required bool isMobile,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Container(
      width: isMobile ? double.infinity : 280,
      margin: isMobile ? const EdgeInsets.all(12) : const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard.withValues(alpha: 0.5) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                _getStatusIcon(status),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${columnTasks.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _showQuickTaskModal(context, status),
                  tooltip: 'Add Task to $title',
                ),
              ],
            ),
          ),

          // Column Task Cards Drag Target / List
          Expanded(
            child: DragTarget<Task>(
              onAcceptWithDetails: (details) {
                taskProvider.updateTaskStatus(details.data.id, status);
              },
              builder: (context, candidateData, rejectedData) {
                if (columnTasks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No tasks in $title',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: columnTasks.length,
                  itemBuilder: (context, index) {
                    final task = columnTasks[index];
                    return Draggable<Task>(
                      data: task,
                      feedback: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: isMobile ? 320 : 260,
                          child: _buildKanbanCard(context, task, isDragging: true),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildKanbanCard(context, task),
                      ),
                      child: _buildKanbanCard(context, task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(BuildContext context, Task task, {bool isDragging = false}) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = AppTheme.getPriorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: InkWell(
        onTap: () => navProvider.openTaskDetailDrawer(task.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Priority Strip & Actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppTheme.getPriorityLabel(task.priority),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: priorityColor),
                    ),
                  ),
                  const Spacer(),
                  if (task.reminders.isNotEmpty)
                    const Icon(Icons.notifications_active_outlined, size: 14, color: Colors.purple),
                  if (task.recurrence != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.autorenew, size: 14, color: AppTheme.accentCyan),
                    ),
                  IconButton(
                    icon: Icon(
                      task.status == TaskStatus.done ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: task.status == TaskStatus.done ? AppTheme.accentEmerald : Colors.grey,
                    ),
                    onPressed: () => taskProvider.toggleTaskStatus(task.id),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                  color: task.status == TaskStatus.done ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                ),
              ),

              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],

              const SizedBox(height: 10),

              // Subtask Progress Bar
              if (task.checklist.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: task.checklistProgress,
                          minHeight: 4,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          color: task.checklistProgress == 1.0 ? AppTheme.accentEmerald : AppTheme.primaryIndigo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${task.completedChecklistCount}/${task.checklist.length}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Footer: Due date & Tag chips
              Row(
                children: [
                  if (task.dueDate != null)
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 12, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('MMM d').format(task.dueDate!),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  const Spacer(),
                  if (task.tags.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBorder : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#${task.tags.first}',
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.backlog:
        return const Icon(Icons.inbox, size: 16, color: Colors.grey);
      case TaskStatus.todo:
        return const Icon(Icons.list_alt, size: 16, color: Colors.amber);
      case TaskStatus.inProgress:
        return const Icon(Icons.pending_actions, size: 16, color: AppTheme.primaryIndigo);
      case TaskStatus.done:
        return const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.accentEmerald);
    }
  }

  void _showQuickTaskModal(BuildContext context, TaskStatus status) {
    showDialog(
      context: context,
      builder: (ctx) => CreateTaskDialog(initialStatus: status),
    );
  }
}
