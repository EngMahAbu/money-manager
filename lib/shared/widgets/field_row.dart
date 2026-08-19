import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_constants.dart';

class FieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isAccent;
  final double padding;
  final VoidCallback? onTap;

  const FieldRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.isAccent = false,
    this.padding = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isAccent ? AppColors.accentContainer : AppColors.surfaceInner;
    final labelColor = isAccent ? AppColors.accentText : AppColors.textMuted;
    final valueColor = isAccent ? AppColors.accentText : AppColors.textPrimary;
    final iconColor = isAccent ? AppColors.accentText : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body.copyWith(color: labelColor)),
            const Spacer(),
            if (value != null)
              Text(
                value!,
                style: AppTextStyles.body.copyWith(color: valueColor),
              ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(TablerIcons.chevron_right, size: 16, color: iconColor),
            ],
          ],
        ),
      ),
    );
  }
}
