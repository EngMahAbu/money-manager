import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TransactionRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String timestamp;
  final String amount;
  final bool isIncome;
  final bool isTransfer;
  final bool showDivider;

  const TransactionRow({
    super.key,
    required this.icon,
    required this.name,
    required this.timestamp,
    required this.amount,
    this.isIncome = false,
    this.isTransfer = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatarBgColor = isTransfer 
        ? AppColors.accentContainer 
        : (isIncome ? AppColors.successContainer : AppColors.dangerContainer);
    final avatarIconColor = isTransfer 
        ? AppColors.accentText 
        : (isIncome ? AppColors.successText : AppColors.dangerText);
    final amountColor = isTransfer 
        ? AppColors.textPrimary 
        : (isIncome ? AppColors.success : AppColors.danger);
    final prefix = isTransfer ? '' : (isIncome ? '+' : '-');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: avatarBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: avatarIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
          const Divider(indent: 56, endIndent: 12),
      ],
    );
  }
}
