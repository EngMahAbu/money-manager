import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentContainer : AppColors.surfaceInner,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.accentText : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              TablerIcons.chevron_down,
              size: 14,
              color: isActive ? AppColors.accentText : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
