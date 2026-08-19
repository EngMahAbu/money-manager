import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TransactionRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String? highlightQuery;
  final String timestamp;
  final String amount;
  final bool isIncome;
  final bool isTransfer;
  final bool showDivider;
  final Color? barColor;
  final Color? avatarBackgroundColor;
  final Color? avatarIconColor;

  const TransactionRow({
    super.key,
    required this.icon,
    required this.name,
    this.highlightQuery,
    required this.timestamp,
    required this.amount,
    this.isIncome = false,
    this.isTransfer = false,
    this.showDivider = true,
    this.barColor,
    this.avatarBackgroundColor,
    this.avatarIconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Use custom colors if provided, otherwise fall back to type-based colors
    final effectiveAvatarBgColor = avatarBackgroundColor 
        ?? (isTransfer 
            ? AppColors.accentContainer 
            : (isIncome ? AppColors.successContainer : AppColors.dangerContainer));
    final effectiveAvatarIconColor = avatarIconColor 
        ?? (isTransfer 
            ? AppColors.accentText 
            : (isIncome ? AppColors.successText : AppColors.dangerText));
    final amountColor = isTransfer 
        ? AppColors.textPrimary 
        : (isIncome ? AppColors.success : AppColors.danger);
    final prefix = isTransfer ? '' : (isIncome ? '+' : '-');
    
    // Determine bar color based on type
    final effectiveBarColor = barColor 
        ?? (isTransfer 
            ? AppColors.accent 
            : (isIncome ? AppColors.success : AppColors.danger));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              // Vertical colored bar representing transaction type
              Container(
                width: 3,
                height: 32,
                decoration: BoxDecoration(
                  color: effectiveBarColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 9),
              // Category icon avatar with ramp color
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: effectiveAvatarBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: effectiveAvatarIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildName(context),
                    Text(timestamp, style: AppTextStyles.muted),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$prefix$amount',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(indent: 68, endIndent: 12),
      ],
    );
  }

  Widget _buildName(BuildContext context) {
    if (highlightQuery == null || highlightQuery!.isEmpty) {
      return Text(
        name,
        style: AppTextStyles.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerName = name.toLowerCase();
    final lowerQuery = highlightQuery!.toLowerCase();
    final startIndex = lowerName.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(
        name,
        style: AppTextStyles.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTextStyles.body,
        children: [
          TextSpan(text: name.substring(0, startIndex)),
          TextSpan(
            text: name.substring(startIndex, startIndex + highlightQuery!.length),
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w500),
          ),
          TextSpan(text: name.substring(startIndex + highlightQuery!.length)),
        ],
      ),
    );
  }
}
