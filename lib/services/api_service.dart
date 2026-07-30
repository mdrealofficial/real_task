import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class ApiService {
  // Domain provided by user - secure HTTPS backend URL
  static const String baseUrl = 'https://tasks.mdrealofficial.com/api/v1';

  /// Authenticate User via HTTPS REST API
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'user': data['user'],
            'token': data['token'],
          };
        }
      }
    } catch (e) {
      debugPrint('API Auth Error: $e');
    }
    return null;
  }

  /// Change Password via HTTPS REST API
  static Future<bool> changePassword(String userId, String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'new_password': newPassword,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      debugPrint('API Change Password Error: $e');
    }
    return false;
  }

  /// Sync Tasks via HTTPS REST API
  static Future<List<Task>?> syncTasks(String userId, String token, List<Task> tasks) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'tasks': tasks.map((t) => t.toJson()).toList(),
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['tasks'] != null) {
          final List<dynamic> list = data['tasks'];
          return list.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('API Task Sync Error: $e');
    }
    return null;
  }
}
