import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_constants.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSuccess;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isSuccess = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSuccess ? AppColors.successContainer : AppColors.dangerContainer;
    final textColor = isSuccess ? AppColors.successText : AppColors.dangerText;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.statValue.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
