import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';

class TopProgressBar extends StatelessWidget {
  const TopProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final percentage = taskProvider.currentCompletionPercentage;
    final completed = taskProvider.currentCompletedCount;
    final total = taskProvider.currentTotalCount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Stats Text Pill Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: isDark ? AppTheme.darkCard.withValues(alpha: 0.5) : Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryIndigo.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics_outlined, size: 14, color: AppTheme.primaryIndigo),
                    const SizedBox(width: 6),
                    Text(
                      '${percentage.toStringAsFixed(0)}% Completed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '($completed of $total tasks done)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (total > 0 && completed == total)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.stars, size: 14, color: AppTheme.accentEmerald),
                      SizedBox(width: 4),
                      Text(
                        'All Done!',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentEmerald),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Horizontal Progress Line
        Container(
          height: 5,
          width: double.infinity,
          color: isDark ? AppTheme.darkBorder : Colors.grey[200],
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double progressWidth = constraints.maxWidth * (percentage / 100.0);
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: progressWidth,
                    height: 5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryIndigo, AppTheme.accentEmerald],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
