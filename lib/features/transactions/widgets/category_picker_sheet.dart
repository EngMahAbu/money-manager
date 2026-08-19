import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../data/database.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/widgets/bottom_sheet_header.dart';

import '../../../l10n/app_localizations.dart';

class CategoryPickerSheet extends StatefulWidget {
  final List<Category> categories;
  final int? selectedCategoryId;
  final Function(Category) onSelected;
  final VoidCallback onAddCategory;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onSelected,
    required this.onAddCategory,
  });

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  late List<Category> _filteredCategories;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
  }

  void _onSearch(String query) {
    setState(() {
      _filteredCategories = widget.categories
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            BottomSheetHeader(title: l10n.chooseCategory),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: l10n.searchCategories,
                  prefixIcon: const Icon(TablerIcons.search, size: 18),
                  filled: true,
                  fillColor: AppColors.surfaceInner,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filteredCategories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  final isSelected = category.id == widget.selectedCategoryId;
                  final roleColor = category.type == CategoryType.income ? AppColors.success : AppColors.danger;
                  final roleContainerColor = category.type == CategoryType.income ? AppColors.successContainer : AppColors.dangerContainer;
                  final roleTextColor = category.type == CategoryType.income ? AppColors.successText : AppColors.dangerText;
        
                  return GestureDetector(
                    onTap: () => widget.onSelected(category),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? (category.type == CategoryType.income ? AppColors.successText : AppColors.dangerText).withValues(alpha: 0.1) // Subtle background in screenshot
                            : AppColors.surfaceInner,
                        borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                        border: isSelected ? Border.all(color: roleTextColor, width: 0.5) : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.transparent : roleContainerColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              // Logic for icon mapping or use generic tag
                              TablerIcons.tag, 
                              size: 18, 
                              color: isSelected ? roleTextColor : roleColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category.name,
                              style: AppTextStyles.body.copyWith(
                                color: isSelected ? roleTextColor : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(TablerIcons.check, color: roleTextColor, size: 20),
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
              title: Text(l10n.addCategoryAction, style: const TextStyle(color: AppColors.accent)),
              onTap: widget.onAddCategory,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
