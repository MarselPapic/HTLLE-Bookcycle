import 'package:flutter/material.dart';

class DesignTokens {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const Color primary = Color(0xFF0B7E87);
  static const Color primaryDark = Color(0xFF066772);
  static const Color secondary = Color(0xFF17C6DC);
  static const Color error = Color(0xFFE5484D);
  static const Color success = Color(0xFF1FA874);
  static const Color background = Color(0xFFF3F5F7);
  static const Color backgroundWarm = Color(0xFFF4F1E6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFE9EEF3);
  static const Color textPrimary = Color(0xFF1A2233);
  static const Color textMuted = Color(0xFF7D8798);
  static const Color border = Color(0xFFDCE3EC);

  static const TextStyle headline = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.4,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textMuted,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const double radius = 16.0;
  static const double radiusSmall = 12.0;
}
