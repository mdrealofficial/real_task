import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/task_provider.dart';
import '../services/alarm_service.dart';
import '../services/network_sync_service.dart';
import '../widgets/sidebar/collapsible_sidebar.dart';
import '../widgets/header/top_header.dart';
import '../widgets/header/top_progress_bar.dart';
import '../widgets/views/task_list_view.dart';
import '../widgets/views/kanban_board_view.dart';
import '../widgets/dialogs/task_detail_drawer.dart';
import '../widgets/dialogs/alarm_overlay_dialog.dart';
import '../widgets/dialogs/create_task_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final alarmService = Provider.of<AlarmService>(context, listen: false);
      final networkSync = Provider.of<NetworkSyncService>(context, listen: false);
      
      alarmService.startMonitoring(taskProvider.tasks);
      networkSync.triggerAutoSync(taskProvider: taskProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final alarmService = Provider.of<AlarmService>(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Collapsible Sidebar Navigation
              const CollapsibleSidebar(),

              // Main Canvas Workspace
              Expanded(
                child: Column(
                  children: [
                    // Top Navigation Header
                    TopHeader(
                      onQuickAdd: () => _showQuickCreateTaskDialog(context),
                    ),

                    // Top Horizontal Progress Bar Line
                    const TopProgressBar(),

                    // Main View Content (List Mode vs Kanban Board Mode)
                    Expanded(
                      child: navProvider.viewMode == ViewMode.list
                          ? const TaskListView()
                          : const KanbanBoardView(),
                    ),
                  ],
                ),
              ),

              // Slide-over Right Task Detail Drawer (when active)
              if (navProvider.activeDrawerTaskId != null)
                TaskDetailDrawer(taskId: navProvider.activeDrawerTaskId!),
            ],
          ),

          // Alarm Overlay Dialog when triggered
          if (alarmService.activeAlarmTask != null)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: const Center(child: AlarmOverlayDialog()),
              ),
            ),
        ],
      ),

      // Mobile Bottom Dock (on small screens)
      bottomNavigationBar: MediaQuery.of(context).size.width < 768
          ? BottomNavigationBar(
              currentIndex: navProvider.mobileTabIndex,
              onTap: (idx) {
                navProvider.setMobileTabIndex(idx);
                if (idx == 0) {
                  Provider.of<TaskProvider>(context, listen: false).setCategory(TaskFilterCategory.today);
                } else if (idx == 1) {
                  navProvider.setViewMode(ViewMode.kanban);
                } else if (idx == 2) {
                  _showQuickCreateTaskDialog(context);
                } else if (idx == 3) {
                  final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                  Provider.of<NetworkSyncService>(context, listen: false).triggerAutoSync(taskProvider: taskProvider);
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
                BottomNavigationBarItem(icon: Icon(Icons.view_kanban), label: 'Kanban'),
                BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add'),
                BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'Sync'),
              ],
            )
          : null,
    );
  }

  void _showQuickCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CreateTaskDialog(),
    );
  }
}
