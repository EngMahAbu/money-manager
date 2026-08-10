import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.sectionHeader),
        if (onActionPressed != null)
          Row(
            children: [
              if (actionLabel != null)
                Text(
                  actionLabel!,
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
              if (actionLabel == null)
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textMuted,
                ),
            ],
          ),
      ],
    );

    if (onActionPressed != null) {
      return GestureDetector(
        onTap: onActionPressed,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
