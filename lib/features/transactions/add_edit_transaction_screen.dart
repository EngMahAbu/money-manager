import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/widgets/field_row.dart';
import '../accounts/cubit/accounts_cubit.dart';
import '../accounts/cubit/accounts_state.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/account_picker_sheet.dart';
import 'widgets/category_picker_sheet.dart';
import 'widgets/date_picker_sheet.dart';
import 'widgets/receipts_strip.dart';
import '../accounts/add_edit_account_screen.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  late TransactionType _selectedType;
  String _amountString = '0';
  String _expression = '';
  bool _isCalculatorExpanded = false;

  Account? _selectedAccount;
  Account? _selectedToAccount;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _note;
  final List<String> _receipts = [];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ?? TransactionType.expense;
    if (widget.transaction != null) {
      _amountString = widget.transaction!.amount.toStringAsFixed(2);
      _selectedDate = widget.transaction!.date;
      _note = widget.transaction!.note;
    }
  }

  void _onTypeChanged(TransactionType type) {
    final l10n = AppLocalizations.of(context)!;
    if (type != _selectedType) {
      if (_selectedType == TransactionType.transfer && _selectedToAccount != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clearToAccountMessage)),
        );
        return;
      }
      if ((_selectedType == TransactionType.income || _selectedType == TransactionType.expense) && _selectedCategory != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clearCategoryMessage)),
        );
        return;
      }
    }
    setState(() {
      _selectedType = type;
    });
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_amountString == '0' && key != '.') {
        _amountString = key;
      } else {
        if (key == '.' && _amountString.contains('.')) return;
        _amountString += key;
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_amountString.length > 1) {
        _amountString = _amountString.substring(0, _amountString.length - 1);
      } else {
        _amountString = '0';
      }
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      _expression += ' $_amountString $op';
      _amountString = '0';
    });
  }

  void _showAccountPicker(bool isToAccount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          final accounts = state is AccountsLoaded ? state.activeAccounts : <Account>[];
          return AccountPickerSheet(
            accounts: accounts,
            selectedAccountId: isToAccount ? _selectedToAccount?.id : _selectedAccount?.id,
            onSelected: (account) {
              setState(() {
                if (isToAccount) {
                  _selectedToAccount = account;
                } else {
                  _selectedAccount = account;
                }
              });
              Navigator.pop(context);
            },
            onAddAccount: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddEditAccountScreen(), fullscreenDialog: true),
              );
            },
          );
        },
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          final filtered = state is CategoriesLoaded 
              ? (_selectedType == TransactionType.income ? state.incomeCategories : state.expenseCategories)
              : <Category>[];

          return CategoryPickerSheet(
            categories: filtered,
            selectedCategoryId: _selectedCategory?.id,
            onSelected: (category) {
              setState(() => _selectedCategory = category);
              Navigator.pop(context);
            },
            onAddCategory: () {
              // TODO: Add Category screen
            },
          );
        },
      ),
    );
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerSheet(
        initialDate: _selectedDate,
        onDateSelected: (date) => setState(() => _selectedDate = date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _selectedType == TransactionType.income
        ? AppColors.success
        : (_selectedType == TransactionType.expense ? AppColors.danger : AppColors.textPrimary);

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.newTransaction),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.check, color: AppColors.accent),
            onPressed: () {
              // TODO: Save implementation
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: ThemeConstants.cardPadding),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Segmented Control
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInner,
                      borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                    ),
                    child: Row(
                      children: [
                        _buildTypeButton(TransactionType.expense, l10n.expense),
                        _buildTypeButton(TransactionType.income, l10n.income),
                        _buildTypeButton(TransactionType.transfer, l10n.transfer),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Amount Display
                  Column(
                    children: [
                      if (_isCalculatorExpanded && _expression.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            _expression,
                            style: AppTextStyles.muted.copyWith(fontSize: 12),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\$$_amountString',
                            style: AppTextStyles.netWorth.copyWith(
                              fontSize: _isCalculatorExpanded ? 32 : 36,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _isCalculatorExpanded = !_isCalculatorExpanded),
                            child: Icon(
                              TablerIcons.calculator,
                              size: 18,
                              color: _isCalculatorExpanded ? AppColors.accent : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Fields
                  Column(
                    children: [
                      FieldRow(
                        icon: TablerIcons.wallet,
                        label: _selectedType == TransactionType.transfer ? l10n.from : l10n.account,
                        value: _selectedAccount?.name ?? 'Select',
                        onTap: () => _showAccountPicker(false),
                      ),
                      const SizedBox(height: 4),
                      if (_selectedType == TransactionType.transfer)
                        FieldRow(
                          icon: TablerIcons.arrow_right,
                          label: l10n.to,
                          value: _selectedToAccount?.name ?? 'Select',
                          isAccent: true,
                          onTap: () => _showAccountPicker(true),
                        )
                      else
                        FieldRow(
                          icon: TablerIcons.category,
                          label: l10n.category,
                          value: _selectedCategory?.name ?? 'Select',
                          onTap: _showCategoryPicker,
                        ),
                      const SizedBox(height: 4),
                      FieldRow(
                        icon: TablerIcons.calendar,
                        label: l10n.date,
                        value: DateUtils.isSameDay(_selectedDate, DateTime.now())
                            ? l10n.today
                            : DateUtils.isSameDay(_selectedDate, DateTime.now().subtract(const Duration(days: 1)))
                                ? l10n.yesterday
                                : DateFormat('MMM d, yyyy').format(_selectedDate),
                        onTap: _showDatePicker,
                      ),
                      const SizedBox(height: 4),
                      _buildNoteField(l10n),
                      const SizedBox(height: 4),
                      _buildReceiptsSection(l10n),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.surfaceInner,
            padding: const EdgeInsets.only(bottom: 12),
            child: NumericKeypad(
              isCalculatorExpanded: _isCalculatorExpanded,
              onKeyPressed: _onKeyPressed,
              onDeletePressed: _onDeletePressed,
              onOperatorPressed: _onOperatorPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(TransactionType type, String label) {
    final isSelected = _selectedType == type;
    Color? bgColor;
    Color? textColor;
    
    if (isSelected) {
      if (type == TransactionType.income) {
        bgColor = AppColors.successContainer;
        textColor = AppColors.successText;
      } else if (type == TransactionType.expense) {
        bgColor = AppColors.dangerContainer;
        textColor = AppColors.dangerText;
      } else {
        bgColor = AppColors.accentContainer;
        textColor = AppColors.accentText;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: textColor ?? AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteField(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) {
            final controller = TextEditingController(text: _note);
            return AlertDialog(
              title: Text(l10n.addNote),
              content: TextField(
                controller: controller,
                maxLength: 150,
                autofocus: true,
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('OK')),
              ],
            );
          },
        );
        if (result != null) setState(() => _note = result);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceInner,
          borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
        ),
        child: Row(
          children: [
            const Icon(TablerIcons.note, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _note?.isEmpty ?? true ? l10n.addNote : _note!,
                style: AppTextStyles.body.copyWith(
                  color: _note?.isEmpty ?? true ? AppColors.textMuted : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptsSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceInner,
        borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(TablerIcons.receipt, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(l10n.receipts, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 8),
          ReceiptsStrip(
            receiptPaths: _receipts,
            onAdd: () {
              if (_receipts.length >= 5) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorReceiptLimit)));
                return;
              }
              setState(() => _receipts.add('mock_path'));
            },
            onRemove: (index) => setState(() => _receipts.removeAt(index)),
          ),
        ],
      ),
    );
  }
}
