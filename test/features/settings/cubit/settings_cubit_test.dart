import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/features/settings/cubit/settings_cubit.dart';
import 'package:money_manager/features/settings/cubit/settings_state.dart';

void main() {
  group('SettingsCubit', () {
    blocTest<SettingsCubit, SettingsState>(
      'updateCurrency updates currency',
      build: () => SettingsCubit(),
      act: (cubit) => cubit.updateCurrency('EUR'),
      expect: () => [
        const SettingsState(currency: 'EUR'),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'updateAppearance updates appearance',
      build: () => SettingsCubit(),
      act: (cubit) => cubit.updateAppearance(AppAppearance.dark),
      expect: () => [
        const SettingsState(appearance: AppAppearance.dark),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'toggleAppLock toggles lock',
      build: () => SettingsCubit(),
      act: (cubit) => cubit.toggleAppLock(true),
      expect: () => [
        const SettingsState(isAppLockEnabled: true),
      ],
    );
  });
}
