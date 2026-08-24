import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/utils/expression_evaluator.dart';
import '../../shared/widgets/field_row.dart';
import '../accounts/add_edit_account_screen.dart';
import '../accounts/cubit/accounts_cubit.dart';
import '../accounts/cubit/accounts_state.dart';
import '../categories/add_edit_category_screen.dart';
import '../categories/cubit/categories_cubit.dart';
import '../categories/cubit/categories_state.dart';
import 'cubit/transactions_cubit.dart';
import 'widgets/account_picker_sheet.dart';
import 'widgets/category_picker_sheet.dart';
import 'widgets/date_picker_sheet.dart';
import 'widgets/numeric_keypad.dart';
import 'widgets/receipts_strip.dart';

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
  bool _shouldReplaceAmount = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ?? TransactionType.expense;
    if (widget.transaction != null) {
      final amount = widget.transaction!.amount;
      _amountString =
      amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(
          2);
      _expression = _amountString;
      _lastValidAmount = _amountString;
      _shouldReplaceAmount = true;
      _selectedDate = widget.transaction!.date;
      _note = widget.transaction!.note;

      // Get accounts and categories from cubits
      final accountsState = context.read<AccountsCubit>().state;
      final categoriesState = context.read<CategoriesCubit>().state;

      if (accountsState is AccountsLoaded) {
        _selectedAccount = accountsState.activeAccounts
            .where((a) => a.id == widget.transaction!.accountId)
            .firstOrNull;

        if (widget.transaction!.toAccountId != null) {
          _selectedToAccount = accountsState.activeAccounts
              .where((a) => a.id == widget.transaction!.toAccountId)
              .firstOrNull;
        }
      }

      if (categoriesState is CategoriesLoaded &&
          widget.transaction!.categoryId != null) {
        final allCategories = [
          ...categoriesState.incomeCategories,
          ...categoriesState.expenseCategories,
          ...categoriesState.archivedCategories,
        ];
        _selectedCategory = allCategories
            .where((c) => c.id == widget.transaction!.categoryId)
            .firstOrNull;
      }
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

  void _toggleCalculator() {
    setState(() {
      _isCalculatorExpanded = !_isCalculatorExpanded;
      // When exiting calculator mode, clear the expression
      // but keep the final amount
      if (!_isCalculatorExpanded) {
        _expression = '';
      } else {
        // Entering calculator mode - initialize expression with current amount
        _shouldReplaceAmount = false;
        if (_expression.isEmpty || _expression == '0') {
          _expression = _amountString;
        }
      }
    });
  }

  void _onKeyPressed(String key) {
    setState(() {
      if (_shouldReplaceAmount) {
        _shouldReplaceAmount = false;
        if (key == '.') {
          _expression = '0.';
        } else {
          _expression = key;
        }
        _lastValidAmount = '0';
      } else {
        // Handle different key types
        if (key == '.') {
          // Allow one decimal point in each number of the expression.
          var lastOperatorIndex = -1;
          for (final operator in '+-×÷'.split('')) {
            lastOperatorIndex =
            lastOperatorIndex < _expression.lastIndexOf(operator)
                ? _expression.lastIndexOf(operator)
                : lastOperatorIndex;
          }
          final currentNumber = _expression.substring(lastOperatorIndex + 1);
          if (currentNumber.contains('.')) return;
          // If expression is empty or ends with operator, start with "0."
          if (_expression.isEmpty ||
              _expression.endsWith('+') ||
              _expression.endsWith('-') ||
              _expression.endsWith('×') ||
              _expression.endsWith('÷')) {
            _expression += '0';
          }
          _expression += key;
        } else {
          // It's a digit
          // If expression is empty or ends with operator (except -), start fresh
          if (_expression.isEmpty ||
              _expression.endsWith('+') ||
              _expression.endsWith('×') ||
              _expression.endsWith('÷')) {
            _expression += key;
          } else if (_expression.endsWith('-') && _expression.length > 1) {
            // Handle negative numbers: if we have "-" and it's not at position 0, just append
            // But if it's at position 0 (like "-5"), we need to check
            final prevChar = _expression[_expression.length - 2];
            if (prevChar == '+' ||
                prevChar == '-' ||
                prevChar == '×' ||
                prevChar == '÷') {
              // The "-" is an operator, start the number
              _expression += key;
            } else {
              // The "-" is part of a negative number, append to it
              _expression += key;
            }
          } else if (_expression == '0') {
            // Replace the 0
            _expression = key;
          } else {
            // Append to the current number
            _expression += key;
          }
        }
      }
      _evaluateAndUpdateAmount();
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_shouldReplaceAmount) {
        _shouldReplaceAmount = false;
        _expression = '0';
      } else {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        if (_expression.isEmpty) {
          _expression = '0';
        }
      }
      _evaluateAndUpdateAmount();
    });
  }

  void _onOperatorPressed(String op) {
    setState(() {
      if (_shouldReplaceAmount) {
        _shouldReplaceAmount = false;
      }

      // If expression is empty or just "0", don't add operator
      if (_expression.isEmpty || _expression == '0') {
        return;
      }

      // If expression already ends with an operator, replace it
      if (_expression.endsWith('+') ||
          _expression.endsWith('-') ||
          _expression.endsWith('×') ||
          _expression.endsWith('÷')) {
        // Replace the last character with the new operator
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        // Add the operator
        _expression += op;
      }
      _evaluateAndUpdateAmount();
    });
  }

  String _lastValidAmount = '0';

  void _evaluateAndUpdateAmount() {
    // Try to evaluate the expression
    try {
      // Only evaluate if the expression is valid (doesn't end with operator)
      if (_expression.isNotEmpty &&
          !_expression.endsWith('+') &&
          !_expression.endsWith('-') &&
          !_expression.endsWith('×') &&
          !_expression.endsWith('÷')) {
        final result = ExpressionEvaluator.evaluate(_expression);
        _amountString = result.toStringAsFixed(2);
        _lastValidAmount = _amountString;
        // Remove trailing .00
        if (_amountString.endsWith('.00')) {
          _amountString = _amountString.substring(0, _amountString.length - 3);
        }
      } else {
        // Incomplete expression - show the last valid amount
        // "a trailing operator with nothing after it is simply ignored"
        _amountString = _lastValidAmount;
      }
    } catch (e) {
      // If evaluation fails, show the last valid amount
      _amountString = _lastValidAmount;
    }
  }

  void _showAccountPicker(bool isToAccount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) {
          final accounts = state is AccountsLoaded ? state.activeAccounts : <Account>[];
          // Determine which account to disable:
          // - If picking "to" account, disable the "from" account
          // - If picking "from" account, disable the "to" account
          final disabledAccountId = isToAccount
              ? _selectedAccount?.id
              : _selectedToAccount?.id;

          return AccountPickerSheet(
            accounts: accounts,
            selectedAccountId: isToAccount ? _selectedToAccount?.id : _selectedAccount?.id,
            disabledAccountId: disabledAccountId,
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
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddEditCategoryScreen(), fullscreenDialog: true),
              );
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountString) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorAmountZero)));
      return;
    }

    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseAccount)));
      return;
    }

    if (_selectedType == TransactionType.transfer) {
      if (_selectedToAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseAccount)));
        return;
      }
      if (_selectedAccount!.id == _selectedToAccount!.id) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorTransferSameAccount)));
        return;
      }

      if (_selectedAccount!.currency != _selectedToAccount!.currency) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text(l10n.transferCurrencyMismatchTitle),
                content: Text(l10n.transferCurrencyMismatch(
                    _selectedAccount!.currency, _selectedToAccount!.currency)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.proceed),
                  ),
                ],
              ),
        );

        if (proceed != true) return;
      }
    } else {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseCategory)));
        return;
      }
    }

    if (!mounted) return;

    final cubit = context.read<TransactionsCubit>();
    if (widget.transaction != null) {
      cubit.updateTransaction(
        widget.transaction!.copyWith(
          accountId: _selectedAccount!.id,
          categoryId: drift.Value(_selectedCategory?.id),
          toAccountId: drift.Value(_selectedToAccount?.id),
          amount: amount,
          date: _selectedDate,
          note: drift.Value(_note),
          receipts: drift.Value(_receipts.join('|')),
          type: _selectedType,
        ),
      );
    } else {
      cubit.addTransaction(
        TransactionsCompanion.insert(
          accountId: _selectedAccount!.id,
          categoryId: drift.Value(_selectedCategory?.id),
          toAccountId: drift.Value(_selectedToAccount?.id),
          amount: amount,
          date: _selectedDate,
          note: drift.Value(_note),
          receipts: drift.Value(_receipts.join('|')),
          type: _selectedType,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _selectedType == TransactionType.income
        ? AppColors.success
        : (_selectedType == TransactionType.expense ? AppColors.danger : AppColors.textPrimary);

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.transaction == null ? l10n.newTransaction : l10n.editTransaction),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.check, color: AppColors.accent),
            onPressed: _save,
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
                            ExpressionEvaluator.formatExpression(_expression),
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
                            onTap: () => _toggleCalculator(),
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
                        padding: _isCalculatorExpanded ? 10 : 12,
                        onTap: () => _showAccountPicker(false),
                      ),
                      const SizedBox(height: 4),
                      if (_selectedType == TransactionType.transfer)
                        FieldRow(
                          icon: TablerIcons.arrow_right,
                          label: l10n.to,
                          value: _selectedToAccount?.name ?? 'Select',
                          isAccent: true,
                          padding: _isCalculatorExpanded ? 10 : 12,
                          onTap: () => _showAccountPicker(true),
                        )
                      else
                        FieldRow(
                          icon: TablerIcons.category,
                          label: l10n.category,
                          value: _selectedCategory?.name ?? 'Select',
                          padding: _isCalculatorExpanded ? 10 : 12,
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
                        padding: _isCalculatorExpanded ? 10 : 12,
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
