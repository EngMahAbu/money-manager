import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_constants.dart';

class ListRow extends StatelessWidget {
  final Widget leading;
  final String label;
  final String? subtitle;
  final String? value;
  final Color? valueColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ListRow({
    super.key,
    required this.leading,
    required this.label,
    this.subtitle,
    this.value,
    this.valueColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: ThemeConstants.rowPaddingVertical,
          horizontal: ThemeConstants.rowPaddingHorizontal,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceInner,
          borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.body),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.muted),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (value != null)
              Text(
                value!,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
