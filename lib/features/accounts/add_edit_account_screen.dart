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

// Currency data model
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

// List of supported currencies
const List<Currency> currencies = [
  Currency(code: 'USD', symbol: '\$', name: 'US dollar'),
  Currency(code: 'EUR', symbol: '€', name: 'Euro'),
  Currency(code: 'GBP', symbol: '£', name: 'British pound'),
  Currency(code: 'AUD', symbol: 'A\$', name: 'Australian dollar'),
  Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian dollar'),
  Currency(code: 'JPY', symbol: '¥', name: 'Japanese yen'),
  Currency(code: 'EGP', symbol: '£E', name: 'Egyptian pound'),
];

// Common currencies (shown in the Common section)
const List<String> commonCurrencyCodes = ['USD', 'EUR', 'EGP'];

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

  // Get the currency object for the currently selected currency
  Currency get _selectedCurrencyObj => currencies.firstWhere(
    (c) => c.code == _selectedCurrency,
    orElse: () => currencies[0],
  );

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

  Future<void> _showCurrencyPicker() async {
    final selected = await showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _CurrencyPickerSheet(selectedCurrency: _selectedCurrencyObj),
    );

    if (selected != null) {
      setState(() => _selectedCurrency = selected.code);
    }
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
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.innerRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
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
                      color: isSelected
                          ? AppColors.accentContainer
                          : AppColors.surfaceInner,
                      borderRadius: BorderRadius.circular(
                        ThemeConstants.innerRadius,
                      ),
                      border: isSelected
                          ? Border.all(color: AppColors.accent, width: 0.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getAccountTypeLabel(type, l10n),
                      style: AppTextStyles.body.copyWith(
                        color: isSelected
                            ? AppColors.accentText
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
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
              label: '$_selectedCurrency — ${_selectedCurrencyObj.name}',
              onTap: _showCurrencyPicker,
            ),
            const SizedBox(height: 20),
            Text(
              _isEdit ? l10n.balance : l10n.startingBalance,
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceInner,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.innerRadius,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              style: AppTextStyles.body.copyWith(
                color: balanceValue < 0
                    ? AppColors.danger
                    : AppColors.textPrimary,
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
                  border: Border(
                    top: BorderSide(color: AppColors.borderDefault, width: 0.5),
                  ),
                ),
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AccountsCubit>().archiveAccount(
                      widget.account!.id,
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    TablerIcons.archive,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                  label: Text(
                    l10n.archiveAccount,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
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
        border: isSelected
            ? Border.all(color: AppColors.accentText, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            )
          : null,
    );
  }

  Widget _buildAddIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderStrong,
          style: BorderStyle.solid,
        ), // Should be dashed
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

// Currency Picker Bottom Sheet Widget
class _CurrencyPickerSheet extends StatefulWidget {
  final Currency selectedCurrency;

  const _CurrencyPickerSheet({required this.selectedCurrency});

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  late List<Currency> _filteredCurrencies;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = List.from(currencies);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCurrencies = currencies.where((currency) {
        return currency.code.toLowerCase().contains(query) ||
            currency.name.toLowerCase().contains(query) ||
            currency.symbol.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surfaceInner,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ThemeConstants.cardRadius * 1.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose currency',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search currencies',
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ThemeConstants.innerRadius,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(
                    TablerIcons.search,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Common section
                    if (_searchController.text.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Common',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildCurrencySection(commonCurrencyCodes),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'All currencies',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // All currencies section
                    ..._buildCurrencySection(
                      _filteredCurrencies.map((c) => c.code).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCurrencySection(List<String> currencyCodes) {
    final widgets = <Widget>[];
    // Remove duplicates while preserving order
    final seen = <String>{};
    final uniqueCodes = currencyCodes.where((code) => seen.add(code)).toList();

    for (final code in uniqueCodes) {
      final currency = currencies.firstWhere((c) => c.code == code);
      final isSelected = widget.selectedCurrency.code == currency.code;

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(currency),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentContainer
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
              ),
              child: Row(
                children: [
                  // Symbol circle
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInner,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currency.symbol,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.accentText
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Code and name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.code,
                        style: AppTextStyles.body.copyWith(
                          color: isSelected
                              ? AppColors.accentText
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                      Text(
                        currency.name,
                        style: AppTextStyles.muted.copyWith(
                          color: isSelected
                              ? AppColors.accentText
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Checkmark
                  if (isSelected)
                    Icon(
                      TablerIcons.check,
                      size: 16,
                      color: AppColors.accentText,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
