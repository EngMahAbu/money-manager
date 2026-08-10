import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../data/database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/widgets/bottom_sheet_header.dart';

import '../../../l10n/app_localizations.dart';

class AccountPickerSheet extends StatelessWidget {
  final List<Account> accounts;
  final int? selectedAccountId;
  final Function(Account) onSelected;
  final VoidCallback onAddAccount;

  const AccountPickerSheet({
    super.key,
    required this.accounts,
    this.selectedAccountId,
    required this.onSelected,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(title: l10n.chooseAccount),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accounts.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = accounts[index];
                final isSelected = account.id == selectedAccountId;
                
                // Determine icon based on type from design doc
                IconData accountIcon;
                switch (account.type) {
                  case AccountType.cash:
                    accountIcon = TablerIcons.wallet;
                    break;
                  case AccountType.bank:
                  case AccountType.savings:
                    accountIcon = TablerIcons.building_bank;
                    break;
                  case AccountType.creditCard:
                    accountIcon = TablerIcons.credit_card;
                    break;
                }

                return GestureDetector(
                  onTap: () => onSelected(account),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.surfaceInner,
                      borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          accountIcon, 
                          size: 20, 
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name,
                                style: AppTextStyles.body.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                ),
                              ),
                              Text(
                                '\$${account.startingBalance.toStringAsFixed(0)}', // Rounded as in screenshot
                                style: AppTextStyles.muted.copyWith(
                                  color: isSelected ? Colors.white.withValues(alpha: 0.7) : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(TablerIcons.check, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(TablerIcons.plus, color: AppColors.accent),
            title: Text(l10n.addAccountAction, style: const TextStyle(color: AppColors.accent)),
            onTap: onAddAccount,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
