enum ReminderType {
  atStart,
  min15Before,
  min30Before,
  hour1Before,
  atEndTime,
}

class ReminderRule {
  final String id;
  final ReminderType type;
  DateTime triggerAt;
  final bool hasAlarmSound;
  bool isTriggered;

  ReminderRule({
    required this.id,
    required this.type,
    required this.triggerAt,
    this.hasAlarmSound = true,
    this.isTriggered = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'triggerAt': triggerAt.toIso8601String(),
      'hasAlarmSound': hasAlarmSound,
      'isTriggered': isTriggered,
    };
  }

  factory ReminderRule.fromJson(Map<String, dynamic> json) {
    return ReminderRule(
      id: json['id'] as String,
      type: ReminderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReminderType.atStart,
      ),
      triggerAt: DateTime.parse(json['triggerAt'] as String),
      hasAlarmSound: json['hasAlarmSound'] as bool? ?? true,
      isTriggered: json['isTriggered'] as bool? ?? false,
    );
  }

  String get label {
    switch (type) {
      case ReminderType.atStart:
        return 'At task start';
      case ReminderType.min15Before:
        return '15 minutes before';
      case ReminderType.min30Before:
        return '30 minutes before';
      case ReminderType.hour1Before:
        return '1 hour before';
      case ReminderType.atEndTime:
        return 'At task end time';
    }
  }
}
