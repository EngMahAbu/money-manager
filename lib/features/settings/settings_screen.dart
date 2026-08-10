import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/theme/theme_constants.dart';
import '../../shared/widgets/list_row.dart';
import '../../shared/widgets/toggle_switch.dart';
import '../accounts/accounts_screen.dart';
import '../categories/categories_screen.dart';
import 'cubit/settings_cubit.dart';
import 'cubit/settings_state.dart';

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
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(ThemeConstants.cardPadding),
            children: [
              _buildSectionHeader(l10n.general),
              _buildGroup([
                ListRow(
                  leading: const Icon(TablerIcons.currency_dollar, size: 20, color: AppColors.textSecondary),
                  label: l10n.defaultCurrency,
                  value: state.currency,
                  trailing: const Icon(TablerIcons.chevron_right, size: 16, color: AppColors.textMuted),
                  onTap: () {
                    // TODO: Open currency picker
                  },
                ),
                ListRow(
                  leading: const Icon(TablerIcons.moon, size: 20, color: AppColors.textSecondary),
                  label: l10n.appearance,
                  value: _getAppearanceLabel(state.appearance, l10n),
                  trailing: const Icon(TablerIcons.chevron_right, size: 16, color: AppColors.textMuted),
                  onTap: () {
                    // TODO: Open appearance picker
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.manage),
              _buildGroup([
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
                ListRow(
                  leading: const Icon(TablerIcons.wallet, size: 20, color: AppColors.textSecondary),
                  label: l10n.accounts,
                  trailing: const Icon(TablerIcons.chevron_right, size: 16, color: AppColors.textMuted),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AccountsScreen()),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.security),
              _buildGroup([
                ListRow(
                  leading: const Icon(TablerIcons.fingerprint, size: 20, color: AppColors.textSecondary),
                  label: l10n.appLock,
                  trailing: AppToggleSwitch(
                    value: state.isAppLockEnabled,
                    onChanged: (val) => context.read<SettingsCubit>().toggleAppLock(val),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.notifications),
              _buildGroup([
                ListRow(
                  leading: const Icon(TablerIcons.bell, size: 20, color: AppColors.textSecondary),
                  label: l10n.dailyReminder,
                  trailing: AppToggleSwitch(
                    value: state.isDailyReminderEnabled,
                    onChanged: (val) => context.read<SettingsCubit>().toggleDailyReminder(val),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.data),
              _buildGroup([
                ListRow(
                  leading: const Icon(TablerIcons.download, size: 20, color: AppColors.textSecondary),
                  label: l10n.exportData,
                  trailing: const Icon(TablerIcons.chevron_right, size: 16, color: AppColors.textMuted),
                  onTap: () {
                    // TODO: Export data logic
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.about),
              _buildGroup([
                const ListRow(
                  leading: Icon(TablerIcons.info_circle, size: 20, color: AppColors.textSecondary),
                  label: 'Version',
                  value: '1.0.0',
                ),
                ListRow(
                  leading: const Icon(TablerIcons.message, size: 20, color: AppColors.textSecondary),
                  label: l10n.sendFeedback,
                  trailing: const Icon(TablerIcons.chevron_right, size: 16, color: AppColors.textMuted),
                  onTap: () {
                    // TODO: Send feedback logic
                  },
                ),
              ]),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Column(
      children: List.generate(children.length, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == children.length - 1 ? 0 : 4),
          child: children[index],
        );
      }),
    );
  }

  String _getAppearanceLabel(AppAppearance appearance, AppLocalizations l10n) {
    switch (appearance) {
      case AppAppearance.system:
        return l10n.system;
      case AppAppearance.light:
        return l10n.light;
      case AppAppearance.dark:
        return l10n.dark;
    }
  }
}
