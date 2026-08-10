import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/theme/theme_constants.dart';
import '../../../shared/widgets/bottom_sheet_header.dart';
import '../../../l10n/app_localizations.dart';

class MultiSelectItem {
  final int id;
  final String label;
  final IconData icon;
  final String? subtitle;

  MultiSelectItem({required this.id, required this.label, required this.icon, this.subtitle});
}

class MultiSelectPickerSheet extends StatefulWidget {
  final String title;
  final List<MultiSelectItem> items;
  final List<int> initialSelectedIds;
  final Function(List<int>) onApply;

  const MultiSelectPickerSheet({
    super.key,
    required this.title,
    required this.items,
    required this.initialSelectedIds,
    required this.onApply,
  });

  @override
  State<MultiSelectPickerSheet> createState() => _MultiSelectPickerSheetState();
}

class _MultiSelectPickerSheetState extends State<MultiSelectPickerSheet> {
  late List<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomSheetHeader(title: widget.title),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.items.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = _selectedIds.contains(item.id);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected ? _selectedIds.remove(item.id) : _selectedIds.add(item.id);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInner,
                      borderRadius: BorderRadius.circular(ThemeConstants.innerRadius),
                      border: isSelected ? Border.all(color: AppColors.accent, width: 0.5) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.label, style: AppTextStyles.body),
                              if (item.subtitle != null)
                                Text(item.subtitle!, style: AppTextStyles.muted),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isSelected ? AppColors.accent : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.accent : AppColors.borderStrong,
                              width: 1,
                            ),
                          ),
                          child: isSelected 
                              ? const Icon(Icons.check, size: 14, color: Colors.white) 
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onApply(_selectedIds),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeConstants.innerRadius)),
                  elevation: 0,
                ),
                child: Text(l10n.apply),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
