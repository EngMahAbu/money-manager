import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/widgets/field_row.dart';
import 'cubit/accounts_cubit.dart';

class AddEditAccountScreen extends StatefulWidget {
  final Account? account;

  const AddEditAccountScreen({super.key, this.account});

  @override
  State<AddEditAccountScreen> createState() => _AddEditAccountScreenState();
}

class _AddEditAccountScreenState extends State<AddEditAccountScreen> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late AccountType _selectedType;
  late String _selectedCurrency;
  String? _selectedIcon;
  Color? _selectedColor;

  bool get _isEdit => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account?.startingBalance.toStringAsFixed(2) ?? '0.00',
    );
    _selectedType = widget.account?.type ?? AccountType.cash;
    _selectedCurrency = widget.account?.currency ?? 'USD';
    _selectedIcon = widget.account?.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    if (_isEdit) {
      context.read<AccountsCubit>().updateAccount(
            widget.account!.copyWith(
              name: name,
              type: _selectedType,
              currency: _selectedCurrency,
              startingBalance: balance,
              icon: drift.Value(_selectedIcon),
            ),
          );
    } else {
      context.read<AccountsCubit>().addAccount(
            AccountsCompanion.insert(
              name: name,
              type: _selectedType,
              currency: drift.Value(_selectedCurrency),
              startingBalance: drift.Value(balance),
              icon: drift.Value(_selectedIcon),
            ),
          );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final balanceValue = double.tryParse(_balanceController.text) ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEdit ? l10n.editAccount : l10n.addAccount),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.check, color: AppColors.accent),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.accountName, style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Main bank',
                filled: true,
                fillColor: AppColors.surfaceInner,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 20),
            Text(l10n.type, style: AppTextStyles.label),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accentContainer : AppColors.surfaceInner,
                      borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                      border: isSelected ? Border.all(color: AppColors.accent, width: 0.5) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getAccountTypeLabel(type, l10n),
                      style: AppTextStyles.body.copyWith(
                        color: isSelected ? AppColors.accentText : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(l10n.currency, style: AppTextStyles.label),
            const SizedBox(height: 6),
            FieldRow(
              icon: TablerIcons.currency_dollar,
              label: '$_selectedCurrency — US dollar',
              onTap: () {
                // TODO: Currency Picker
              },
            ),
            const SizedBox(height: 20),
            Text(_isEdit ? l10n.balance : l10n.startingBalance, style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceInner,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              style: AppTextStyles.body.copyWith(
                color: balanceValue < 0 ? AppColors.danger : AppColors.textPrimary,
              ),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 4),
              Text(
                l10n.balanceHelper,
                style: AppTextStyles.muted.copyWith(fontSize: 11),
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.iconAndColor, style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildIconSwatch(TablerIcons.building_bank, isSelected: true),
                const SizedBox(width: 10),
                _buildIconSwatch(TablerIcons.wallet),
                const SizedBox(width: 10),
                _buildIconSwatch(TablerIcons.credit_card),
                const SizedBox(width: 10),
                _buildIconSwatch(null), // Empty circle
                const SizedBox(width: 10),
                _buildAddIcon(),
              ],
            ),
            const SizedBox(height: 40),
            if (_isEdit)
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderDefault, width: 0.5)),
                ),
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AccountsCubit>().archiveAccount(widget.account!.id);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(TablerIcons.archive, color: AppColors.textMuted, size: 16),
                  label: Text(
                    l10n.archiveAccount,
                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSwatch(IconData? icon, {bool isSelected = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : AppColors.surfaceInner,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: AppColors.accentText, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: icon != null 
          ? Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textSecondary)
          : null,
    );
  }

  Widget _buildAddIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong, style: BorderStyle.solid), // Should be dashed
      ),
      alignment: Alignment.center,
      child: const Icon(TablerIcons.plus, size: 18, color: AppColors.textMuted),
    );
  }

  String _getAccountTypeLabel(AccountType type, AppLocalizations l10n) {
    switch (type) {
      case AccountType.cash:
        return l10n.cashAccount;
      case AccountType.bank:
        return l10n.bankAccount;
      case AccountType.creditCard:
        return l10n.creditCardAccount;
      case AccountType.savings:
        return l10n.savingsAccount;
    }
  }
}
