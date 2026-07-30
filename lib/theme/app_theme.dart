import 'package:flutter/material.dart';
import '../models/task_model.dart';

class AppTheme {
  // Brand & Accent Colors
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Priority Tokens
  static const Color p1Urgent = Color(0xFFEF4444);
  static const Color p2High = Color(0xFFF59E0B);
  static const Color p3Medium = Color(0xFF3B82F6);
  static const Color p4Low = Color(0xFF94A3B8);

  // Light Mode Tokens
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSidebar = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark Mode Tokens
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkSidebar = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  static Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.p1:
        return p1Urgent;
      case TaskPriority.p2:
        return p2High;
      case TaskPriority.p3:
        return p3Medium;
      case TaskPriority.p4:
        return p4Low;
    }
  }

  static String getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.p1:
        return 'P1 (Urgent)';
      case TaskPriority.p2:
        return 'P2 (High)';
      case TaskPriority.p3:
        return 'P3 (Medium)';
      case TaskPriority.p4:
        return 'P4 (Low)';
    }
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: primaryIndigo,
      secondary: accentEmerald,
      surface: lightCard,
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryIndigo,
      secondary: accentEmerald,
      surface: darkCard,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      iconTheme: IconThemeData(color: darkTextPrimary),
    ),
  );
}
