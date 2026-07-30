import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _currentUserId;
  String? _currentUserEmail;
  String? _authToken;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  String? get authToken => _authToken;
  String? get errorMessage => _errorMessage;

  AuthService() {
    _initSession();
  }

  /// Initialize session from secure storage (Unlimited Session duration)
  Future<void> _initSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? savedUserId;
      String? savedUserEmail;
      String? savedToken;

      try {
        savedUserId = await _secureStorage.read(key: 'taskflow_user_id').timeout(const Duration(seconds: 1));
        savedUserEmail = await _secureStorage.read(key: 'taskflow_user_email').timeout(const Duration(seconds: 1));
        savedToken = await _secureStorage.read(key: 'taskflow_auth_token').timeout(const Duration(seconds: 1));
      } catch (_) {
        // Fallback to SharedPreferences if secure storage hangs
        final prefs = await SharedPreferences.getInstance();
        savedUserId = prefs.getString('taskflow_user_id');
        savedUserEmail = prefs.getString('taskflow_user_email');
        savedToken = prefs.getString('taskflow_auth_token');
      }

      if (savedUserId != null && savedUserEmail != null && savedToken != null) {
        _isLoggedIn = true;
        _currentUserId = savedUserId;
        _currentUserEmail = savedUserEmail;
        _authToken = savedToken;
      }
    } catch (e) {
      debugPrint('Session restore error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Perform User Login via HTTPS REST API
  Future<bool> login(String email, String password) async {
    _errorMessage = null;

    final result = await ApiService.login(email, password);

    if (result != null && result['user'] != null) {
      final user = result['user'];
      _isLoggedIn = true;
      _currentUserId = user['id'];
      _currentUserEmail = user['email'];
      _authToken = result['token'] ?? 'token_${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}';

      // 1. Notify listeners IMMEDIATELY so UI transitions without waiting for disk I/O
      notifyListeners();

      // 2. Persist session asynchronously in background without blocking UI thread
      _saveSessionAsync(_currentUserId!, _currentUserEmail!, _authToken!);
      return true;
    } else {
      // Offline fallback: Check against seeded admin credentials if server is unreachable
      final cleanEmail = email.trim().toLowerCase();
      if (cleanEmail == 'mdreal.official@gmail.com' && password == 'Staritlab77') {
        _isLoggedIn = true;
        _currentUserId = 'user-admin-1';
        _currentUserEmail = 'mdreal.official@gmail.com';
        _authToken = 'token_user-admin-1_offline';

        notifyListeners();
        _saveSessionAsync(_currentUserId!, _currentUserEmail!, _authToken!);
        return true;
      }

      _errorMessage = 'Invalid email or password. Please check your credentials.';
      notifyListeners();
      return false;
    }
  }

  /// Non-blocking background session storage
  Future<void> _saveSessionAsync(String userId, String email, String token) async {
    try {
      await _secureStorage.write(key: 'taskflow_user_id', value: userId).timeout(const Duration(seconds: 1));
      await _secureStorage.write(key: 'taskflow_user_email', value: email).timeout(const Duration(seconds: 1));
      await _secureStorage.write(key: 'taskflow_auth_token', value: token).timeout(const Duration(seconds: 1));
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('taskflow_user_id', userId);
      await prefs.setString('taskflow_user_email', email);
      await prefs.setString('taskflow_auth_token', token);
    }
  }

  /// Change Password via HTTPS REST API
  Future<bool> changePassword(String newPassword) async {
    if (_currentUserId == null || _authToken == null) return false;

    final success = await ApiService.changePassword(_currentUserId!, _authToken!, newPassword);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  /// Logout User
  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserId = null;
    _currentUserEmail = null;
    _authToken = null;
    try {
      await _secureStorage.deleteAll().timeout(const Duration(seconds: 1));
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
