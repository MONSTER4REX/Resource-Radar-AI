import 'package:flutter/material.dart';

/// App-wide design constants for the ResourceRadar Field Agent theme.
class AppColors {
  // Primary palette — Emergency/humanitarian inspired
  static const Color primary = Color(0xFF0D47A1);       // Deep blue — trust
  static const Color primaryLight = Color(0xFF5472D3);
  static const Color primaryDark = Color(0xFF002171);

  // Accent — Action / urgency
  static const Color accent = Color(0xFFFF6D00);         // Vivid orange
  static const Color accentLight = Color(0xFFFF9E40);

  // Urgency tiers
  static const Color urgencyCritical = Color(0xFFD32F2F);
  static const Color urgencyHigh = Color(0xFFFF6D00);
  static const Color urgencyMedium = Color(0xFFFFA726);
  static const Color urgencyLow = Color(0xFF66BB6A);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // Surface
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8EAF6);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textHint = Color(0xFF9AA0A6);
  static const Color divider = Color(0xFFE0E0E0);

  // Offline indicator
  static const Color offline = Color(0xFF757575);
  static const Color online = Color(0xFF4CAF50);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 999;
}
