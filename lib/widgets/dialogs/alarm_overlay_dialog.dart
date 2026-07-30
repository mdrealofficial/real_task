import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/alarm_service.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';

class AlarmOverlayDialog extends StatelessWidget {
  const AlarmOverlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final alarmService = Provider.of<AlarmService>(context);
    final task = alarmService.activeAlarmTask;
    final reminder = alarmService.activeReminder;

    if (task == null || reminder == null) return const SizedBox.shrink();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_on, color: Colors.purple, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              '⏰ Task Alarm Alert!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryIndigo),
            ),
            const SizedBox(height: 6),
            Text(
              reminder.label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (task.startTime != null && task.endTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Time Window: ${task.startTime} - ${task.endTime}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      alarmService.snoozeAlarm(const Duration(minutes: 15));
                    },
                    child: const Text('Snooze 15m'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentEmerald, foregroundColor: Colors.white),
                    onPressed: () {
                      Provider.of<TaskProvider>(context, listen: false).toggleTaskStatus(task.id);
                      alarmService.dismissAlarm();
                    },
                    child: const Text('Mark Done'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => alarmService.dismissAlarm(),
              child: const Text('Dismiss Alarm', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
