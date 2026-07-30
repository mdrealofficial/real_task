import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../models/checklist_model.dart';
import '../models/recurrence_model.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const String _tasksKey = 'taskflow_tasks_list';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);

    if (jsonString == null || jsonString.isEmpty) {
      // Seed default sample tasks for a rich first-run experience
      final initialTasks = _generateSeedTasks();
      await saveTasks(initialTasks);
      return initialTasks;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _generateSeedTasks();
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, jsonString);
  }

  static List<Task> _generateSeedTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 'task-1',
        title: 'Design System Review & Color Palette Tokens',
        description: 'Review Slate/Zinc themes, HSL priority badges, and modern glassmorphism UI specs.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.p1,
        dueDate: now,
        startTime: '10:00',
        endTime: '11:30',
        tags: ['UI/UX', 'Design'],
        reminders: [
          ReminderRule(
            id: 'rem-1',
            type: ReminderType.min15Before,
            triggerAt: now.add(const Duration(minutes: 15)),
          ),
          ReminderRule(
            id: 'rem-2',
            type: ReminderType.atEndTime,
            triggerAt: now.add(const Duration(hours: 1, minutes: 30)),
          ),
        ],
        checklist: [
          ChecklistItem(id: 'c1', title: 'Setup Light & Dark theme tokens', isCompleted: true, order: 1),
          ChecklistItem(id: 'c2', title: 'Verify P1-P4 contrast ratios', isCompleted: true, order: 2),
          ChecklistItem(id: 'c3', title: 'Add animated progress bar line', isCompleted: false, order: 3),
        ],
      ),
      Task(
        id: 'task-2',
        title: 'Weekly Standup & Local Network Sync Verification',
        description: 'Test P2P mDNS discovery and QR Code device pairing over Wi-Fi.',
        status: TaskStatus.todo,
        priority: TaskPriority.p2,
        dueDate: now,
        startTime: '14:00',
        endTime: '15:00',
        tags: ['Sync', 'Meeting'],
        recurrence: RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 1,
          mode: RecurrenceMode.fixedSchedule,
        ),
        reminders: [
          ReminderRule(
            id: 'rem-3',
            type: ReminderType.atStart,
            triggerAt: now.add(const Duration(hours: 4)),
          ),
        ],
        checklist: [
          ChecklistItem(id: 'c4', title: 'Connect MacBook & iPhone to local Wi-Fi', isCompleted: false, order: 1),
          ChecklistItem(id: 'c5', title: 'Scan QR code & verify E2EE handshake', isCompleted: false, order: 2),
        ],
      ),
      Task(
        id: 'task-3',
        title: 'Refactor Kanban Board & Drag-and-Drop Handler',
        description: 'Optimize drag-and-drop column responsiveness for desktop & mobile touch viewports.',
        status: TaskStatus.done,
        priority: TaskPriority.p3,
        dueDate: now.subtract(const Duration(days: 1)),
        tags: ['Flutter', 'Dev'],
        completedAt: now.subtract(const Duration(hours: 2)),
        checklist: [
          ChecklistItem(id: 'c6', title: 'Implement ReorderableListView columns', isCompleted: true, order: 1),
          ChecklistItem(id: 'c7', title: 'Add mobile swipeable Kanban tabs', isCompleted: true, order: 2),
        ],
      ),
      Task(
        id: 'task-4',
        title: 'Grocery & Health Supplements',
        description: 'Take vitamin supplement every 3 days.',
        status: TaskStatus.todo,
        priority: TaskPriority.p4,
        dueDate: now.add(const Duration(days: 1)),
        tags: ['Health'],
        recurrence: RecurrenceRule(
          frequency: RecurrenceFrequency.daily,
          interval: 3,
          mode: RecurrenceMode.completionBased,
        ),
        checklist: [
          ChecklistItem(id: 'c8', title: 'Buy Multivitamins', isCompleted: false, order: 1),
          ChecklistItem(id: 'c9', title: 'Buy Omega-3', isCompleted: false, order: 2),
        ],
      ),
    ];
  }
}
