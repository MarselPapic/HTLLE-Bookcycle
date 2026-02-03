import 'package:flutter/material.dart';

class DesignTokens {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const Color primary = Color(0xFF2F5CFF);
  static const Color secondary = Color(0xFF17A2B8);
  static const Color error = Color(0xFFE03131);
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1F2B);
  static const Color textMuted = Color(0xFF5C6475);

  static const TextStyle headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  static const double radius = 12.0;
}
