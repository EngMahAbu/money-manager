import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/widgets/list_row.dart';
import '../categories/categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(ThemeConstants.cardPadding),
        children: [
          ListRow(
            leading: const Icon(TablerIcons.category, size: 20, color: AppColors.textSecondary),
            label: l10n.categories,
            trailing: const Icon(TablerIcons.chevron_right, size: 16, color: AppColors.textMuted),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CategoriesScreen()),
              );
            },
          ),
          // More settings will be added here in Task 5.8
        ],
      ),
    );
  }
}
