enum RecurrenceFrequency { daily, weekly, monthly }
enum RecurrenceMode { fixedSchedule, completionBased }

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval; // e.g. every X days/weeks/months
  final List<int>? daysOfWeek; // 1=Mon, 7=Sun
  final RecurrenceMode mode;
  final bool resetChecklist;

  RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.daysOfWeek,
    this.mode = RecurrenceMode.fixedSchedule,
    this.resetChecklist = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'frequency': frequency.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'mode': mode.name,
      'resetChecklist': resetChecklist,
    };
  }

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurrenceFrequency.daily,
      ),
      interval: json['interval'] as int? ?? 1,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)?.map((e) => e as int).toList(),
      mode: RecurrenceMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => RecurrenceMode.fixedSchedule,
      ),
      resetChecklist: json['resetChecklist'] as bool? ?? true,
    );
  }

  RecurrenceRule copyWith({
    RecurrenceFrequency? frequency,
    int? interval,
    List<int>? daysOfWeek,
    RecurrenceMode? mode,
    bool? resetChecklist,
  }) {
    return RecurrenceRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      mode: mode ?? this.mode,
      resetChecklist: resetChecklist ?? this.resetChecklist,
    );
  }

  String get displayLabel {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return interval == 1 ? 'Every day' : 'Every $interval days';
      case RecurrenceFrequency.weekly:
        return interval == 1 ? 'Every week' : 'Every $interval weeks';
      case RecurrenceFrequency.monthly:
        return interval == 1 ? 'Every month' : 'Every $interval months';
    }
  }
}
