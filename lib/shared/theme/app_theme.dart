import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'theme_constants.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surfacePage,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        surface: AppColors.surfaceCard,
        onSurface: AppColors.textPrimary,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.netWorth,
        titleMedium: AppTextStyles.statValue,
        titleSmall: AppTextStyles.sectionHeader,
        bodyMedium: AppTextStyles.body,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.muted,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.cardRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDefault,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
