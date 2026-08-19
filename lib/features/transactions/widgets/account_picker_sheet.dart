import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../data/database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/widgets/bottom_sheet_header.dart';

import '../../../l10n/app_localizations.dart';
import '../../../repositories/account_repository.dart';

class AccountPickerSheet extends StatefulWidget {
  final List<Account> accounts;
  final int? selectedAccountId;
  final int? disabledAccountId;
  final Function(Account) onSelected;
  final VoidCallback onAddAccount;

  const AccountPickerSheet({
    super.key,
    required this.accounts,
    this.selectedAccountId,
    this.disabledAccountId,
    required this.onSelected,
    required this.onAddAccount,
  });

  @override
  State<AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends State<AccountPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accountRepository = context.read<AccountRepository>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(Size.fromHeight(MediaQuery.sizeOf(context).height * 0.7)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomSheetHeader(title: l10n.chooseAccount),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.accounts.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final account = widget.accounts[index];
                  
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
        
                  final isDisabled = widget.disabledAccountId != null && account.id == widget.disabledAccountId;
                  
                  return StreamBuilder<double>(
                    stream: accountRepository.watchAccountBalance(account.id),
                    initialData: account.startingBalance,
                    builder: (context, snapshot) {
                      final currentBalance = snapshot.data ?? account.startingBalance;
                      final isSelected = account.id == widget.selectedAccountId;
                      
                      return Opacity(
                        opacity: isDisabled ? 0.5 : 1.0,
                        child: IgnorePointer(
                          ignoring: isDisabled,
                          child: GestureDetector(
                            onTap: isDisabled ? null : () => widget.onSelected(account),
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
                                          '\$${currentBalance.toStringAsFixed(2)}',
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
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(TablerIcons.plus, color: AppColors.accent),
              title: Text(l10n.addAccountAction, style: const TextStyle(color: AppColors.accent)),
              onTap: widget.onAddAccount,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
