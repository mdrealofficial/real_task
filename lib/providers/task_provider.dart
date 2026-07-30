import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/checklist_model.dart';
import '../models/recurrence_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';

enum TaskFilterCategory { today, upcoming, inbox, recurring, work, personal, health }

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  TaskFilterCategory _activeCategory = TaskFilterCategory.today;
  String? _selectedTag;
  final Uuid _uuid = const Uuid();
  AuthService? _authService;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TaskFilterCategory get activeCategory => _activeCategory;
  String? get selectedTag => _selectedTag;

  TaskProvider() {
    _init();
  }

  void updateAuthService(AuthService authService) {
    final wasLoggedIn = _authService?.isLoggedIn ?? false;
    _authService = authService;

    if (authService.isLoggedIn && !wasLoggedIn) {
      syncWithServer();
    }
  }

  Future<void> syncWithServer() async {
    if (_authService != null && _authService!.isLoggedIn) {
      final userId = _authService!.currentUserId;
      if (userId == null || userId.isEmpty) return;
      final token = _authService!.authToken ?? '';
      try {
        final syncedTasks = await ApiService.syncTasks(userId, token, _tasks);
        if (syncedTasks != null) {
          _tasks = syncedTasks;
          await StorageService.saveTasks(_tasks);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      } catch (e) {
        debugPrint('Task Sync Error: $e');
      }
    }
  }

  Future<void> _init() async {
    _tasks = await StorageService.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(TaskFilterCategory category) {
    _activeCategory = category;
    _selectedTag = null;
    notifyListeners();
  }

  void setTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.status == TaskStatus.done).length;
    final percentage = total > 0 ? (completed / total) * 100 : 0.0;

    WidgetService.updateHomeScreenWidget(
      completionPercentage: percentage,
      completedCount: completed,
      totalCount: total,
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Task> get filteredTasks {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _tasks.where((task) {
      // Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(q);
        final matchesDesc = task.description?.toLowerCase().contains(q) ?? false;
        final matchesTag = task.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchesTitle && !matchesDesc && !matchesTag) return false;
      }

      // Tag Filter
      if (_selectedTag != null && !task.tags.contains(_selectedTag)) {
        return false;
      }

      // Category Filter
      switch (_activeCategory) {
        case TaskFilterCategory.today:
          if (task.dueDate == null) return false;
          return task.dueDate!.isBefore(todayEnd);
        case TaskFilterCategory.upcoming:
          if (task.dueDate == null) return false;
          return task.dueDate!.isAfter(todayEnd);
        case TaskFilterCategory.inbox:
          return task.status == TaskStatus.backlog || task.dueDate == null;
        case TaskFilterCategory.recurring:
          return task.recurrence != null;
        case TaskFilterCategory.work:
          return task.tags.contains('Work') || task.tags.contains('Dev') || task.tags.contains('Design');
        case TaskFilterCategory.personal:
          return task.tags.contains('Personal') || task.tags.contains('Shopping');
        case TaskFilterCategory.health:
          return task.tags.contains('Health');
      }
    }).toList();
  }

  // Completion Statistics for Top Progress Bar
  int get currentTotalCount => filteredTasks.length;
  int get currentCompletedCount => filteredTasks.where((t) => t.status == TaskStatus.done).length;

  double get currentCompletionPercentage {
    if (currentTotalCount == 0) return 0.0;
    return (currentCompletedCount / currentTotalCount) * 100.0;
  }
  
  void replaceTasksFromSync(List<Task> syncedTasks) {
    _tasks = syncedTasks;
    _updateHomeWidget();
    StorageService.saveTasks(_tasks);
    notifyListeners();
  }

  void _updateHomeWidget() {
    WidgetService.updateHomeScreenWidget(
      completionPercentage: currentCompletionPercentage,
      completedCount: currentCompletedCount,
      totalCount: currentTotalCount,
    );
  }

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    await StorageService.saveTasks(_tasks);
    notifyListeners();
    syncWithServer();
  }

  Future<void> createQuickTask(String title, {TaskPriority priority = TaskPriority.p3}) async {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      priority: priority,
      dueDate: DateTime.now(),
      status: TaskStatus.todo,
    );
    await addTask(newTask);
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task.copyWith(updatedAt: DateTime.now());
      await StorageService.saveTasks(_tasks);
      notifyListeners();
      syncWithServer();
    }
  }

  Future<void> toggleTaskStatus(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final currentTask = _tasks[index];
      final isDone = currentTask.status == TaskStatus.done;
      final newStatus = isDone ? TaskStatus.todo : TaskStatus.done;
      
      Task updatedTask = currentTask.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.done ? DateTime.now() : null,
      );

      // Handle Recurring Task completion behavior
      if (newStatus == TaskStatus.done && currentTask.recurrence != null) {
        _handleRecurringCompletion(currentTask);
      }

      _tasks[index] = updatedTask;
      await StorageService.saveTasks(_tasks);
      notifyListeners();
      syncWithServer();
    }
  }

  void _handleRecurringCompletion(Task task) {
    final rec = task.recurrence!;
    DateTime nextDueDate;
    final now = DateTime.now();

    if (rec.mode == RecurrenceMode.completionBased) {
      nextDueDate = now.add(Duration(days: rec.interval));
    } else {
      final base = task.dueDate ?? now;
      switch (rec.frequency) {
        case RecurrenceFrequency.daily:
          nextDueDate = base.add(Duration(days: rec.interval));
          break;
        case RecurrenceFrequency.weekly:
          nextDueDate = base.add(Duration(days: 7 * rec.interval));
          break;
        case RecurrenceFrequency.monthly:
          nextDueDate = DateTime(base.year, base.month + rec.interval, base.day);
          break;
      }
    }

    // Clone reset checklist if required
    final newChecklist = task.checklist.map((c) {
      return c.copyWith(isCompleted: rec.resetChecklist ? false : c.isCompleted);
    }).toList();

    final nextTask = Task(
      id: _uuid.v4(),
      title: task.title,
      description: task.description,
      status: TaskStatus.todo,
      priority: task.priority,
      projectId: task.projectId,
      tags: List.from(task.tags),
      dueDate: nextDueDate,
      startTime: task.startTime,
      endTime: task.endTime,
      recurrence: task.recurrence,
      checklist: newChecklist,
    );

    _tasks.insert(0, nextTask);
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.done ? DateTime.now() : null,
      );
      await StorageService.saveTasks(_tasks);
      notifyListeners();
      syncWithServer();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await StorageService.saveTasks(_tasks);
    notifyListeners();
    syncWithServer();
  }

  Future<void> toggleChecklistItem(String taskId, String itemId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final checklist = task.checklist.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList();

      _tasks[taskIndex] = task.copyWith(checklist: checklist);
      await StorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> addChecklistItem(String taskId, String title) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final newItem = ChecklistItem(
        id: _uuid.v4(),
        title: title,
        order: task.checklist.length + 1,
      );
      final newChecklist = List<ChecklistItem>.from(task.checklist)..add(newItem);

      _tasks[taskIndex] = task.copyWith(checklist: newChecklist);
      await StorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }
}
