import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_constants.dart';

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

class CurrencyPickerSheet extends StatefulWidget {
  final Currency selectedCurrency;

  const CurrencyPickerSheet({super.key, required this.selectedCurrency});

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
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
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(
          Size.fromHeight(MediaQuery.sizeOf(context).height * 0.7),
        ),
        child: Container(
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
