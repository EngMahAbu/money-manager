import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BottomSheetHeader extends StatelessWidget {
  final String title;

  const BottomSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderStrong,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: AppTextStyles.sectionHeader.copyWith(fontSize: 16)),
        const SizedBox(height: 16),
      ],
    );
  }
}
