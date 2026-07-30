import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';

class TopHeader extends StatelessWidget {
  final VoidCallback onQuickAdd;
  final bool isMobile;

  const TopHeader({
    super.key,
    required this.onQuickAdd,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          final isVeryNarrow = constraints.maxWidth < 450;

          return Row(
            children: [
              // Mobile Hamburger Menu Button to open drawer overlay
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.menu, size: 20),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: 'Open Menu',
                ),

              // Category Title
              Expanded(
                child: Text(
                  _getCategoryTitle(taskProvider.activeCategory),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isVeryNarrow ? 13 : 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Flexible Search Field (Collapses to Icon on Very Narrow Screens)
              if (!isVeryNarrow)
                Flexible(
                  child: Container(
                    height: 36,
                    constraints: const BoxConstraints(maxWidth: 150, minWidth: 70),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBg : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                    ),
                    child: TextField(
                      onChanged: (val) => taskProvider.setSearchQuery(val),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 12),
                      ),
                    ),
                  ),
                ),

              const SizedBox(width: 4),

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
                      label: isNarrow ? '' : 'List',
                      isSelected: navProvider.viewMode == ViewMode.list,
                      onTap: () => navProvider.setViewMode(ViewMode.list),
                    ),
                    _buildViewToggleButton(
                      context: context,
                      icon: Icons.view_kanban_outlined,
                      label: isNarrow ? '' : 'Kanban',
                      isSelected: navProvider.viewMode == ViewMode.kanban,
                      onTap: () => navProvider.setViewMode(ViewMode.kanban),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // New Task Button
              ElevatedButton.icon(
                onPressed: onQuickAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: isVeryNarrow ? 6 : 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(isVeryNarrow ? 'New' : 'New Task', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppTheme.darkCard : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryIndigo : Colors.grey,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? (isDark ? Colors.white : AppTheme.darkCard) : Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(TaskFilterCategory category) {
    switch (category) {
      case TaskFilterCategory.today:
        return "Today's Tasks";
      case TaskFilterCategory.upcoming:
        return 'Upcoming Tasks';
      case TaskFilterCategory.inbox:
        return 'Inbox & Backlog';
      case TaskFilterCategory.recurring:
        return 'Recurring Tasks';
      case TaskFilterCategory.work:
        return 'Work & Development';
      case TaskFilterCategory.personal:
        return 'Personal Tasks';
      case TaskFilterCategory.health:
        return 'Health & Wellness';
    }
  }
}
