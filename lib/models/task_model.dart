import 'dart:convert';
import 'checklist_model.dart';
import 'recurrence_model.dart';
import 'reminder_model.dart';

enum TaskPriority { p1, p2, p3, p4 }

enum TaskStatus { backlog, todo, inProgress, done }

class Task {
  final String id;
  String title;
  String? description;
  TaskStatus status;
  TaskPriority priority;
  String? projectId;
  List<String> tags;
  DateTime? dueDate;
  String? startTime; // "14:00"
  String? endTime;   // "15:30"
  List<ReminderRule> reminders;
  RecurrenceRule? recurrence;
  List<ChecklistItem> checklist;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? completedAt;
  int version;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.p3,
    this.projectId,
    List<String>? tags,
    this.dueDate,
    this.startTime,
    this.endTime,
    List<ReminderRule>? reminders,
    this.recurrence,
    List<ChecklistItem>? checklist,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completedAt,
    this.version = 1,
  })  : tags = tags ?? [],
        reminders = reminders ?? [],
        checklist = checklist ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get checklistProgress {
    if (checklist.isEmpty) return 0.0;
    final completed = checklist.where((c) => c.isCompleted).length;
    return completed / checklist.length;
  }

  int get completedChecklistCount => checklist.where((c) => c.isCompleted).length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'projectId': projectId,
      'tags': tags,
      'dueDate': dueDate?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'recurrence': recurrence?.toJson(),
      'checklist': checklist.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'version': version,
    };
  }

  factory Task.fromJson(Map<String, dynamic> jsonMap) {
    // Parse tags
    List<String> parsedTags = [];
    if (jsonMap['tags'] != null && jsonMap['tags'] is List) {
      parsedTags = (jsonMap['tags'] as List).map((e) => e.toString()).toList();
    } else if (jsonMap['tags_json'] != null && jsonMap['tags_json'].toString().isNotEmpty) {
      parsedTags = jsonMap['tags_json'].toString().split(',');
    }

    // Parse checklist
    List<ChecklistItem> parsedChecklist = [];
    final rawChecklist = jsonMap['checklist'] ?? jsonMap['checklist_json'];
    if (rawChecklist != null) {
      dynamic listData = rawChecklist;
      if (listData is String && listData.isNotEmpty) {
        try {
          listData = json.decode(listData);
        } catch (_) {}
      }
      if (listData is List) {
        parsedChecklist = listData.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    // Parse reminders
    List<ReminderRule> parsedReminders = [];
    final rawReminders = jsonMap['reminders'] ?? jsonMap['reminders_json'];
    if (rawReminders != null) {
      dynamic listData = rawReminders;
      if (listData is String && listData.isNotEmpty) {
        try {
          listData = json.decode(listData);
        } catch (_) {}
      }
      if (listData is List) {
        parsedReminders = listData.map((e) => ReminderRule.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    // Parse recurrence
    RecurrenceRule? parsedRecurrence;
    final rawRec = jsonMap['recurrence'] ?? jsonMap['recurrence_json'];
    if (rawRec != null) {
      dynamic recData = rawRec;
      if (recData is String && recData.isNotEmpty) {
        try {
          recData = json.decode(recData);
        } catch (_) {}
      }
      if (recData is Map<String, dynamic>) {
        parsedRecurrence = RecurrenceRule.fromJson(recData);
      }
    }

    // Parse Dates
    final rawDueDate = jsonMap['dueDate'] ?? jsonMap['due_date'];
    final rawCreatedAt = jsonMap['createdAt'] ?? jsonMap['created_at'];
    final rawUpdatedAt = jsonMap['updatedAt'] ?? jsonMap['updated_at'];
    final rawCompletedAt = jsonMap['completedAt'] ?? jsonMap['completed_at'];

    return Task(
      id: jsonMap['id'] as String,
      title: jsonMap['title'] as String,
      description: jsonMap['description'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == jsonMap['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == jsonMap['priority'],
        orElse: () => TaskPriority.p3,
      ),
      projectId: (jsonMap['projectId'] ?? jsonMap['project_id']) as String?,
      tags: parsedTags,
      dueDate: rawDueDate != null ? DateTime.tryParse(rawDueDate.toString()) : null,
      startTime: (jsonMap['startTime'] ?? jsonMap['start_time']) as String?,
      endTime: (jsonMap['endTime'] ?? jsonMap['end_time']) as String?,
      reminders: parsedReminders,
      recurrence: parsedRecurrence,
      checklist: parsedChecklist,
      createdAt: rawCreatedAt != null ? (DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now()) : DateTime.now(),
      updatedAt: rawUpdatedAt != null ? (DateTime.tryParse(rawUpdatedAt.toString()) ?? DateTime.now()) : DateTime.now(),
      completedAt: rawCompletedAt != null ? DateTime.tryParse(rawCompletedAt.toString()) : null,
      version: jsonMap['version'] as int? ?? 1,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    List<String>? tags,
    DateTime? dueDate,
    String? startTime,
    String? endTime,
    List<ReminderRule>? reminders,
    RecurrenceRule? recurrence,
    List<ChecklistItem>? checklist,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? version,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminders: reminders ?? this.reminders,
      recurrence: recurrence ?? this.recurrence,
      checklist: checklist ?? this.checklist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
      version: version ?? (this.version + 1),
    );
  }
}
