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
      text: widget.account?.startingBalance.toString() ?? '0.00',
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEdit ? l10n.editAccount : l10n.addAccount),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.accountName,
                border: InputBorder.none,
              ),
              style: AppTextStyles.statValue,
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
              childAspectRatio: 2.5,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accentContainer : AppColors.surfaceInner,
                      borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                      border: isSelected ? Border.all(color: AppColors.accent) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      type.name,
                      style: AppTextStyles.body.copyWith(
                        color: isSelected ? AppColors.accentText : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            FieldRow(
              icon: TablerIcons.currency_dollar,
              label: l10n.currency,
              value: _selectedCurrency,
              onTap: () {
                // TODO: Currency Picker
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.balance,
                hintText: '0.00',
                prefixIcon: const Icon(TablerIcons.calculator, size: 18),
                helperText: l10n.balanceHelper,
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.iconAndColor, style: AppTextStyles.label),
            const SizedBox(height: 8),
            // TODO: Icon & Color swatches
            const SizedBox(height: 40),
            if (_isEdit)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AccountsCubit>().archiveAccount(widget.account!.id);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(TablerIcons.archive, color: AppColors.textMuted),
                  label: Text(l10n.archiveAccount, style: const TextStyle(color: AppColors.textMuted)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
