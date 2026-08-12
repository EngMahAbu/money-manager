import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_dimens.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: ColorScheme.light(
        surface: AppColors.surfacePage,
        primary: AppColors.accent,
        secondary: AppColors.accent,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.surfacePage,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfacePage,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.sectionHeader,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          side: const BorderSide(color: AppColors.borderDefault, width: 0.5),
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
