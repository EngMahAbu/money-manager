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
  // Success (Green)
  static const Color success = Color(0xFF1F9D63);
  static const Color successContainer = Color(0xFFE4F6EC);
  static const Color successText = Color(0xFF167A4C);

  // Danger (Coral/Red)
  static const Color danger = Color(0xFFE15241);
  static const Color dangerContainer = Color(0xFFFBEAE7);
  static const Color dangerText = Color(0xFFC2432F);

  // Accent (Blue)
  static const Color accent = Color(0xFF3E7CB8);
  static const Color accentContainer = Color(0xFFE8F1F9);
  static const Color accentText = Color(0xFF2E5F8D);

  // Chart Ramp Colors
  static const List<ChartColorSet> chartRamp = [
    ChartColorSet(
      fill: Color(0xFF8B7FD9),
      container: Color(0xFFEFEDFB),
      text: Color(0xFF6C5FC0),
    ),
    ChartColorSet(
      fill: Color(0xFF2FA88C),
      container: Color(0xFFE3F5F0),
      text: Color(0xFF237E68),
    ),
    ChartColorSet(
      fill: Color(0xFFE77A5D),
      container: Color(0xFFFBEEE8),
      text: Color(0xFFC15F44),
    ),
    ChartColorSet(
      fill: Color(0xFFD96B95),
      container: Color(0xFFFBEBF1),
      text: Color(0xFFB84E76),
    ),
    ChartColorSet(
      fill: Color(0xFF5B8FCC),
      container: Color(0xFFEAF1FA),
      text: Color(0xFF3F6FA8),
    ),
    ChartColorSet(
      fill: Color(0xFFE0A63E),
      container: Color(0xFFFCF2E0),
      text: Color(0xFFB3811F),
    ),
  ];
}

class ChartColorSet {
  final Color fill;
  final Color container;
  final Color text;

  const ChartColorSet({
    required this.fill,
    required this.container,
    required this.text,
  });
}
