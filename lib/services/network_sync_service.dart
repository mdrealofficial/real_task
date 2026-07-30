import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../providers/task_provider.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NetworkSyncService extends ChangeNotifier {
  final AuthService _authService;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSyncedAt;

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  NetworkSyncService(this._authService) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      _isOnline = hasConnection;
      notifyListeners();

      if (hasConnection && _authService.isLoggedIn) {
        // Instant Auto-Sync over HTTPS REST API when network is available
        triggerAutoSync();
      }
    });
  }

  Future<void> triggerAutoSync({TaskProvider? taskProvider}) async {
    if (_isSyncing || !_authService.isLoggedIn) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      final token = _authService.authToken ?? '';
      final currentTasks = taskProvider?.tasks ?? [];

      final syncedTasks = await ApiService.syncTasks(userId, token, currentTasks);
      if (syncedTasks != null && taskProvider != null) {
        taskProvider.replaceTasksFromSync(syncedTasks);
      }

      _lastSyncedAt = DateTime.now();
      _isOnline = true;
    } catch (e) {
      debugPrint('Auto Sync Error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
