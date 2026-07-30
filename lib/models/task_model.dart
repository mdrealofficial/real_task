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

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.p3,
      ),
      projectId: json['projectId'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      reminders: (json['reminders'] as List<dynamic>?)
              ?.map((e) => ReminderRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recurrence: json['recurrence'] != null
          ? RecurrenceRule.fromJson(json['recurrence'] as Map<String, dynamic>)
          : null,
      checklist: (json['checklist'] as List<dynamic>?)
              ?.map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      version: json['version'] as int? ?? 1,
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
