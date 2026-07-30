import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/auth_service.dart';
import '../../services/network_sync_service.dart';
import '../../theme/app_theme.dart';
import '../dialogs/change_password_dialog.dart';

class CollapsibleSidebar extends StatelessWidget {
  const CollapsibleSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final networkSync = Provider.of<NetworkSyncService>(context);

    final isCollapsed = navProvider.isSidebarCollapsed;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSidebar : AppTheme.lightSidebar;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isCollapsed ? 64 : 240,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          // Header Logo & Toggle
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_box_outlined, color: AppTheme.primaryIndigo, size: 20),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'TaskFlow',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                    size: 20,
                  ),
                  onPressed: () => navProvider.toggleSidebar(),
                  tooltip: isCollapsed ? 'Expand Sidebar (Cmd+[)' : 'Collapse Sidebar (Cmd+[)',
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Views Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.inbox_outlined,
                  label: 'Inbox',
                  count: taskProvider.tasks.where((t) => t.status == TaskStatus.backlog).length,
                  isSelected: taskProvider.activeCategory == TaskFilterCategory.inbox,
                  isCollapsed: isCollapsed,
                  onTap: () => taskProvider.setCategory(TaskFilterCategory.inbox),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.today_outlined,
                  label: 'Today',
                  count: taskProvider.tasks.where((t) => t.dueDate != null).length,
                  isSelected: taskProvider.activeCategory == TaskFilterCategory.today,
                  isCollapsed: isCollapsed,
                  onTap: () => taskProvider.setCategory(TaskFilterCategory.today),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.calendar_month_outlined,
                  label: 'Upcoming',
                  isSelected: taskProvider.activeCategory == TaskFilterCategory.upcoming,
                  isCollapsed: isCollapsed,
                  onTap: () => taskProvider.setCategory(TaskFilterCategory.upcoming),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.autorenew_outlined,
                  label: 'Recurring Tasks',
                  count: taskProvider.tasks.where((t) => t.recurrence != null).length,
                  isSelected: taskProvider.activeCategory == TaskFilterCategory.recurring,
                  isCollapsed: isCollapsed,
                  onTap: () => taskProvider.setCategory(TaskFilterCategory.recurring),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1),
                ),

                if (!isCollapsed)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'PROJECTS & TAGS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),

                _buildNavItem(
                  context: context,
                  icon: Icons.folder_outlined,
                  label: 'Work & Dev',
                  iconColor: Colors.amber,
                  isSelected: taskProvider.activeCategory == TaskFilterCategory.work,
                  isCollapsed: isCollapsed,
                  onTap: () => taskProvider.setCategory(TaskFilterCategory.work),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  label: 'Personal',
                  iconColor: Colors.blue,
                  isSelected: taskProvider.activeCategory == TaskFilterCategory.personal,
                  isCollapsed: isCollapsed,
                  onTap: () => taskProvider.setCategory(TaskFilterCategory.personal),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.favorite_outline,
                  label: 'Health & Wellness',
                  iconColor: Colors.pinkAccent,
                  isSelected: taskProvider.activeCategory == TaskFilterCategory.health,
                  isCollapsed: isCollapsed,
                  onTap: () => taskProvider.setCategory(TaskFilterCategory.health),
                ),
              ],
            ),
          ),

          // Network Sync Status Badge
          const Divider(height: 1),
          InkWell(
            onTap: () => networkSync.triggerAutoSync(taskProvider: taskProvider),
            child: Container(
              padding: EdgeInsets.all(isCollapsed ? 12 : 14),
              child: Row(
                mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    networkSync.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: networkSync.isOnline ? AppTheme.accentEmerald : Colors.amber,
                    size: 20,
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            networkSync.isOnline ? 'REST API Auto-Sync' : 'Offline Mode',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            networkSync.isOnline ? 'tasks.mdrealofficial.com' : 'Local Cached',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.refresh, size: 14, color: Colors.grey),
                  ],
                ],
              ),
            ),
          ),

          // User Profile & Settings Section
          const Divider(height: 1),
          if (!isCollapsed) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primaryIndigo,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authService.currentUserEmail ?? 'User',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.lock_reset, size: 18),
                    onPressed: () => showDialog(context: context, builder: (_) => const ChangePasswordDialog()),
                    tooltip: 'Change Password',
                  ),
                  IconButton(
                    icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18),
                    onPressed: () => navProvider.toggleTheme(),
                    tooltip: 'Toggle Theme',
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                    onPressed: () => authService.logout(),
                    tooltip: 'Sign Out',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Task Flow v1.0.2',
                style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
            ),
            const SizedBox(height: 6),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.lock_reset, size: 18),
              onPressed: () => showDialog(context: context, builder: (_) => const ChangePasswordDialog()),
              tooltip: 'Change Password',
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
              onPressed: () => authService.logout(),
              tooltip: 'Sign Out',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    int? count,
    Color? iconColor,
    required bool isSelected,
    required bool isCollapsed,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBg = isDark ? AppTheme.primaryIndigo.withValues(alpha: 0.2) : AppTheme.primaryIndigo.withValues(alpha: 0.1);
    final activeText = AppTheme.primaryIndigo;

    Widget content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeText : (iconColor ?? (isDark ? Colors.grey[300] : Colors.grey[700])),
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? activeText : (isDark ? Colors.grey[200] : Colors.grey[800]),
                  ),
                ),
              ),
              if (count != null && count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryIndigo : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: count != null ? '$label ($count)' : label,
        child: content,
      );
    }
    return content;
  }
}
