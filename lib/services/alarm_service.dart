import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/task_model.dart';
import '../models/reminder_model.dart';

class AlarmService extends ChangeNotifier {
  Timer? _checkTimer;
  Task? _activeAlarmTask;
  ReminderRule? _activeReminder;
  final AudioPlayer _audioPlayer = AudioPlayer();

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
            playAlarmSound();
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  /// Play a high-quality alarm sound chime
  Future<void> playAlarmSound() async {
    try {
      // Play high-frequency chime sound URL or source
      await _audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
    } catch (e) {
      debugPrint('Error playing alarm tone: $e');
    }
  }

  /// Trigger a live test alarm with chime sound sound check
  void triggerTestAlarm([Task? task]) {
    final sampleTask = task ?? Task(
      id: 'test-sample',
      title: 'Sample Test Task Alarm',
      priority: TaskPriority.p1,
      startTime: '09:00 AM',
      endTime: '10:00 AM',
    );

    final testReminder = ReminderRule(
      id: 'test-rem-${DateTime.now().millisecondsSinceEpoch}',
      type: ReminderType.min15Before,
      triggerAt: DateTime.now(),
      hasAlarmSound: true,
    );

    _activeAlarmTask = sampleTask;
    _activeReminder = testReminder;
    playAlarmSound();
    notifyListeners();
  }

  void dismissAlarm() {
    _audioPlayer.stop();
    _activeAlarmTask = null;
    _activeReminder = null;
    notifyListeners();
  }

  void snoozeAlarm(Duration duration) {
    _audioPlayer.stop();
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
    _audioPlayer.dispose();
    super.dispose();
  }
}
