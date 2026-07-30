import 'package:flutter/material.dart';

enum ViewMode { list, kanban }

class NavigationProvider extends ChangeNotifier {
  bool _isSidebarCollapsed = false;
  ViewMode _viewMode = ViewMode.kanban;
  ThemeMode _themeMode = ThemeMode.system;
  int _mobileTabIndex = 0;
  String? _activeDrawerTaskId;

  bool get isSidebarCollapsed => _isSidebarCollapsed;
  ViewMode get viewMode => _viewMode;
  ThemeMode get themeMode => _themeMode;
  int get mobileTabIndex => _mobileTabIndex;
  String? get activeDrawerTaskId => _activeDrawerTaskId;

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setSidebarCollapsed(bool collapsed) {
    _isSidebarCollapsed = collapsed;
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  void setMobileTabIndex(int index) {
    _mobileTabIndex = index;
    notifyListeners();
  }

  void openTaskDetailDrawer(String taskId) {
    _activeDrawerTaskId = taskId;
    notifyListeners();
  }

  void closeTaskDetailDrawer() {
    _activeDrawerTaskId = null;
    notifyListeners();
  }
}
