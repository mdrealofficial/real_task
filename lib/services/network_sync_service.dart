import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../providers/task_provider.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NetworkSyncService extends ChangeNotifier {
  final AuthService _authService;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _pollingTimer;

  bool _isSyncing = false;
  bool _isOnline = true;
  DateTime? _lastSyncedAt;
  TaskProvider? _attachedTaskProvider;

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  NetworkSyncService(this._authService) {
    _initConnectivityListener();
    _startContinuousRealtimeSync();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      _isOnline = hasConnection;
      notifyListeners();

      if (hasConnection && _authService.isLoggedIn) {
        triggerAutoSync();
      }
    });
  }

  void _startContinuousRealtimeSync() {
    _pollingTimer?.cancel();
    // 3-Second Background Auto-Polling for Instant Cross-Platform Synchronization
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_isOnline && _authService.isLoggedIn && !_isSyncing) {
        triggerAutoSync(taskProvider: _attachedTaskProvider);
      }
    });
  }

  Future<void> triggerAutoSync({TaskProvider? taskProvider}) async {
    if (taskProvider != null) {
      _attachedTaskProvider = taskProvider;
    }
    if (_isSyncing || !_authService.isLoggedIn) return;

    _isSyncing = true;

    try {
      final userId = _authService.currentUserId!;
      final token = _authService.authToken ?? '';
      final currentTasks = _attachedTaskProvider?.tasks ?? [];

      final syncedTasks = await ApiService.syncTasks(userId, token, currentTasks);
      if (syncedTasks != null && _attachedTaskProvider != null) {
        _attachedTaskProvider!.replaceTasksFromSync(syncedTasks);
      }

      _lastSyncedAt = DateTime.now();
      _isOnline = true;
    } catch (e) {
      debugPrint('Real-time Auto Sync Error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
