import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import 'cubit/categories_cubit.dart';
import '../../data/daos.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  late TextEditingController _nameController;
  late CategoryType _selectedType;
  late String _selectedIcon;
  bool _isTypeLocked = false;

  final List<String> _availableIcons = [
    'shopping_cart',
    'bolt',
    'car',
    'movie',
    'medical_cross',
    'briefcase',
    'gift',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.category?.type ?? CategoryType.expense;
    _selectedIcon = widget.category?.icon ?? _availableIcons.first;

    if (widget.category != null) {
      _checkIfTypeLocked();
    }
  }

  Future<void> _checkIfTypeLocked() async {
    final dao = context.read<AppDao>();
    final hasTransactions = await dao.categoryHasTransactions(widget.category!.id);
    if (mounted) {
      setState(() {
        _isTypeLocked = hasTransactions;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (widget.category != null) {
      context.read<CategoriesCubit>().updateCategory(
        widget.category!.copyWith(
          name: name,
          type: _selectedType,
          icon: drift.Value(_selectedIcon),
        ),
      );
    } else {
      context.read<CategoriesCubit>().addCategory(
        CategoriesCompanion.insert(
          name: name,
          type: _selectedType,
          icon: drift.Value(_selectedIcon),
          sortOrder: const drift.Value(0), // Repository will override this
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.category != null;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEdit ? l10n.editCategory : l10n.addCategory),
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
            Text(l10n.categoryName, style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Groceries',
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
            const SizedBox(height: 24),
            Text(l10n.type, style: AppTextStyles.label),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeButton(CategoryType.expense, l10n.expense, AppColors.danger),
                const SizedBox(width: 8),
                _buildTypeButton(CategoryType.income, l10n.income, AppColors.success),
              ],
            ),
            if (_isTypeLocked) ...[
              const SizedBox(height: 4),
              Text(
                l10n.errorLockedCategoryType,
                style: AppTextStyles.muted.copyWith(fontSize: 11, color: AppColors.dangerText),
              ),
            ],
            const SizedBox(height: 24),
            Text(l10n.iconAndColor, style: AppTextStyles.label),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._availableIcons.map((icon) => _buildIconSwatch(icon)),
                _buildAddIconSwatch(),
              ],
            ),
            if (isEdit) ...[
              const SizedBox(height: 40),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderDefault, width: 0.5)),
                ),
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () {
                    context.read<CategoriesCubit>().archiveCategory(widget.category!.id);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(TablerIcons.archive, color: AppColors.textMuted, size: 16),
                  label: Text(
                    l10n.archiveCategory,
                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(CategoryType type, String label, Color color) {
    final isSelected = _selectedType == type;
    final isLocked = _isTypeLocked && !isSelected;

    return Expanded(
      child: GestureDetector(
        onTap: isLocked ? null : () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceInner,
            borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
            border: isSelected ? Border.all(color: color, width: 0.5) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? color : AppColors.textSecondary.withValues(alpha: isLocked ? 0.3 : 1.0),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSwatch(String iconName) {
    final isSelected = _selectedIcon == iconName;
    final isIncome = _selectedType == CategoryType.income;
    final activeColor = isIncome ? AppColors.success : AppColors.danger;

    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = iconName),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : AppColors.surfaceInner,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: activeColor, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          _getIconData(iconName),
          size: 20,
          color: isSelected ? activeColor : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAddIconSwatch() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderStrong, style: BorderStyle.solid),
      ),
      alignment: Alignment.center,
      child: const Icon(TablerIcons.plus, size: 20, color: AppColors.textMuted),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'briefcase': return TablerIcons.briefcase;
      case 'gift': return TablerIcons.gift;
      case 'shopping_cart': return TablerIcons.shopping_cart;
      case 'bolt': return TablerIcons.bolt;
      case 'movie': return TablerIcons.movie;
      case 'car': return TablerIcons.car;
      case 'medical_cross': return TablerIcons.medical_cross;
      default: return TablerIcons.category;
    }
  }
}
