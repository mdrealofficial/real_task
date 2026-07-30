import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/reminder_model.dart';

class AlarmService extends ChangeNotifier {
  Timer? _checkTimer;
  Task? _activeAlarmTask;
  ReminderRule? _activeReminder;

  Task? get activeAlarmTask => _activeAlarmTask;
  ReminderRule? get activeReminder => _activeReminder;

  void startMonitoring(List<Task> tasks) {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _evaluateReminders(tasks);
    });
  }

  void stopMonitoring() {
    _checkTimer?.cancel();
  }

  void _evaluateReminders(List<Task> tasks) {
    if (_activeAlarmTask != null) return; // Currently showing an alarm dialog

    final now = DateTime.now();
    for (final task in tasks) {
      if (task.status == TaskStatus.done) continue;

      for (final reminder in task.reminders) {
        if (!reminder.isTriggered) {
          // If trigger time is reached or passed (within 5 min buffer)
          final difference = now.difference(reminder.triggerAt).inSeconds;
          if (difference >= 0 && difference <= 300) {
            reminder.isTriggered = true;
            _activeAlarmTask = task;
            _activeReminder = reminder;
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  void triggerTestAlarm(Task task) {
    final testReminder = ReminderRule(
      id: 'test-rem-${DateTime.now().millisecondsSinceEpoch}',
      type: ReminderType.min15Before,
      triggerAt: DateTime.now(),
      hasAlarmSound: true,
    );
    _activeAlarmTask = task;
    _activeReminder = testReminder;
    notifyListeners();
  }

  void dismissAlarm() {
    _activeAlarmTask = null;
    _activeReminder = null;
    notifyListeners();
  }

  void snoozeAlarm(Duration duration) {
    if (_activeReminder != null) {
      _activeReminder!.triggerAt = DateTime.now().add(duration);
      _activeReminder!.isTriggered = false;
    }
    _activeAlarmTask = null;
    _activeReminder = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
