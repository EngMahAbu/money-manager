import 'package:flutter/material.dart';

class AppColors {
  // Surfaces
  static const Color surfacePage = Color(0xFFF1EEE6);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceInner = Color(0xFFF1EEE6);

  // Text
  static const Color textPrimary = Color(0xFF1C1B18);
  static const Color textSecondary = Color(0xFF716F65);
  static const Color textMuted = Color(0xFFA6A399);

  // Borders
  static const Color borderDefault = Color(0xFFE6E2D6);
  static const Color borderStrong = Color(0xFFCFCBBB);

  // Semantic roles
  static const Color success = Color(0xFF1F9D63);
  static const Color successContainer = Color(0xFFE4F6EC);
  static const Color successText = Color(0xFF167A4C);

  static const Color danger = Color(0xFFE15241);
  static const Color dangerContainer = Color(0xFFFBEAE7);
  static const Color dangerText = Color(0xFFC2432F);

  static const Color accent = Color(0xFF3E7CB8);
  static const Color accentContainer = Color(0xFFE8F1F9);
  static const Color accentText = Color(0xFF2E5F8D);

  // Rotating color ramp for charts
  static const List<Color> chartRamp = [
    Color(0xFF8B7FD9), // Purple
    Color(0xFF2FA88C), // Teal
    Color(0xFFE77A5D), // Coral
    Color(0xFFD96B95), // Pink
    Color(0xFF5B8FCC), // Blue
    Color(0xFFE0A63E), // Amber
  ];
}
