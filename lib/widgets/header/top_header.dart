import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';

class TopHeader extends StatelessWidget {
  final VoidCallback onQuickAdd;

  const TopHeader({super.key, required this.onQuickAdd});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          return Row(
            children: [
              // Category Title
              Text(
                _getCategoryTitle(taskProvider.activeCategory),
                style: TextStyle(
                  fontSize: isCompact ? 15 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),

              // Search Field
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkBg : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                  ),
                  child: TextField(
                    onChanged: (val) => taskProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: isCompact ? 'Search...' : 'Search tasks (Cmd+K)',
                      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 16, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // View Mode Selector (List vs Kanban)
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBg : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildViewToggleButton(
                      context: context,
                      icon: Icons.view_list_outlined,
                      label: isCompact ? '' : 'List',
                      isSelected: navProvider.viewMode == ViewMode.list,
                      onTap: () => navProvider.setViewMode(ViewMode.list),
                    ),
                    _buildViewToggleButton(
                      context: context,
                      icon: Icons.view_kanban_outlined,
                      label: isCompact ? '' : 'Kanban',
                      isSelected: navProvider.viewMode == ViewMode.kanban,
                      onTap: () => navProvider.setViewMode(ViewMode.kanban),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // New Task Button
              ElevatedButton.icon(
                onPressed: onQuickAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(isCompact ? 'New' : 'New Task', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildViewToggleButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppTheme.darkCard : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryIndigo : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(TaskFilterCategory category) {
    switch (category) {
      case TaskFilterCategory.today:
        return 'Today\'s Tasks';
      case TaskFilterCategory.upcoming:
        return 'Upcoming Schedule';
      case TaskFilterCategory.inbox:
        return 'Inbox & Backlog';
      case TaskFilterCategory.recurring:
        return 'Recurring Tasks';
      case TaskFilterCategory.work:
        return 'Work & Development';
      case TaskFilterCategory.personal:
        return 'Personal';
      case TaskFilterCategory.health:
        return 'Health & Wellness';
    }
  }
}
