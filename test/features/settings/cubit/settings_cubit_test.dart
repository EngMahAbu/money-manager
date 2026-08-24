import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:money_manager/features/settings/cubit/settings_cubit.dart';
import 'package:money_manager/features/settings/cubit/settings_state.dart';
import 'package:money_manager/repositories/settings_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late SettingsRepository settingsRepository;

  setUp(() {
    settingsRepository = MockSettingsRepository();
    when(() => settingsRepository.getDefaultCurrency()).thenReturn('USD');
    when(() => settingsRepository.getAppearance()).thenReturn(null);
    when(() => settingsRepository.getAppLockEnabled()).thenReturn(false);
    when(() => settingsRepository.getDailyReminderEnabled()).thenReturn(false);
    when(() => settingsRepository.setDefaultCurrency(any())).thenAnswer((
        _) async {});
    when(() => settingsRepository.setAppearance(any())).thenAnswer((
        _) async {});
    when(() => settingsRepository.setAppLockEnabled(any())).thenAnswer((
        _) async {});
    when(() => settingsRepository.setDailyReminderEnabled(any())).thenAnswer((
        _) async {});
  });

  group('SettingsCubit', () {
    blocTest<SettingsCubit, SettingsState>(
      'updateCurrency updates currency',
      build: () => SettingsCubit(settingsRepository),
      act: (cubit) => cubit.updateCurrency('EUR'),
      expect: () => [
        const SettingsState(currency: 'EUR'),
      ],
      verify: (_) {
        verify(() => settingsRepository.setDefaultCurrency('EUR')).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'updateAppearance updates appearance',
      build: () => SettingsCubit(settingsRepository),
      act: (cubit) => cubit.updateAppearance(AppAppearance.dark),
      expect: () => [
        const SettingsState(appearance: AppAppearance.dark),
      ],
      verify: (_) {
        verify(() => settingsRepository.setAppearance('dark')).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'toggleAppLock toggles lock',
      build: () => SettingsCubit(settingsRepository),
      act: (cubit) => cubit.toggleAppLock(true),
      expect: () => [
        const SettingsState(isAppLockEnabled: true),
      ],
      verify: (_) {
        verify(() => settingsRepository.setAppLockEnabled(true)).called(1);
      },
    );
  });
}
