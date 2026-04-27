import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — Water/Ocean theme
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1565C0);

  // Accent
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentTeal = Color(0xFF009688);

  // Background
  static const Color backgroundLight = Color(0xFFF5F9FF);
  static const Color backgroundDark = Color(0xFF0D1B2A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1B2838);
  static const Color cardDark = Color(0xFF243447);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textDark = Color(0xFFB0BEC5);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Water levels
  static const Color waterLow = Color(0xFFFF7043);
  static const Color waterMedium = Color(0xFFFFA726);
  static const Color waterHigh = Color(0xFF66BB6A);
  static const Color waterFull = Color(0xFF42A5F5);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1B3A4B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color getWaterLevelColor(double percentage) {
    if (percentage >= 1.0) return waterFull;
    if (percentage >= 0.7) return waterHigh;
    if (percentage >= 0.4) return waterMedium;
    return waterLow;
  }
}
