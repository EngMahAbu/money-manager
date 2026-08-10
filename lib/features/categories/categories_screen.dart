import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../data/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import 'cubit/categories_cubit.dart';
import 'cubit/categories_state.dart';
import 'add_edit_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _isArchivedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.categories),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.plus, color: AppColors.accent),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddEditCategoryScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoriesLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(l10n.income, AppColors.success),
                  _buildCategoryList(state.incomeCategories, CategoryType.income),
                  const SizedBox(height: 24),
                  _buildSectionHeader(l10n.expense, AppColors.danger),
                  _buildCategoryList(state.expenseCategories, CategoryType.expense),
                  
                  if (state.archivedCategories.isNotEmpty) ...[
                    const Divider(height: 48),
                    _buildArchivedSection(state.archivedCategories, l10n),
                  ],
                ],
              ),
            );
          }

          if (state is CategoriesError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, CategoryType type) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      onReorderItem: (oldIndex, newIndex) {
        final items = List<Category>.from(categories);
        final item = items.removeAt(oldIndex);
        items.insert(newIndex, item);
        context.read<CategoriesCubit>().reorderCategories(
          items.map((c) => c.id).toList(),
          type,
        );
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryRow(
          key: ValueKey(category.id),
          category: category,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditCategoryScreen(category: category),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArchivedSection(List<Category> archived, AppLocalizations l10n) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isArchivedExpanded = !_isArchivedExpanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.archivedWithCount(archived.length),
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                ),
                Icon(
                  _isArchivedExpanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (_isArchivedExpanded)
          ...archived.map((category) => Opacity(
            opacity: 0.6,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CategoryRow(
                category: category,
                isArchived: true,
                onRestore: () => context.read<CategoriesCubit>().restoreCategory(category.id),
              ),
            ),
          )),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onRestore;
  final bool isArchived;

  const _CategoryRow({
    super.key,
    required this.category,
    this.onTap,
    this.onRestore,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = category.type == CategoryType.income;
    final badgeColor = isIncome ? AppColors.successContainer : AppColors.dangerContainer;
    final iconColor = isIncome ? AppColors.successText : AppColors.dangerText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
            ),
            child: Row(
              children: [
                if (!isArchived) ...[
                  const Icon(TablerIcons.grip_vertical, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                ],
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    size: 15,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isArchived)
                  TextButton(
                    onPressed: onRestore,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.restore,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return TablerIcons.category;
    // Map string to IconData - this should ideally be in a shared utility
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
