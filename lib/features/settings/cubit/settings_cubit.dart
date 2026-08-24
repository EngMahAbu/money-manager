import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsCubit(this._settingsRepository) : super(const SettingsState());

  void loadSettings() {
    emit(state.copyWith(
      currency: _settingsRepository.getDefaultCurrency(),
      appearance: _mapStringToAppearance(_settingsRepository.getAppearance()),
      isAppLockEnabled: _settingsRepository.getAppLockEnabled(),
      isDailyReminderEnabled: _settingsRepository.getDailyReminderEnabled(),
    ));
  }

  Future<void> updateCurrency(String currency) async {
    await _settingsRepository.setDefaultCurrency(currency);
    emit(state.copyWith(currency: currency));
  }

  Future<void> updateAppearance(AppAppearance appearance) async {
    await _settingsRepository.setAppearance(appearance.name);
    emit(state.copyWith(appearance: appearance));
  }

  Future<void> toggleAppLock(bool enabled) async {
    await _settingsRepository.setAppLockEnabled(enabled);
    emit(state.copyWith(isAppLockEnabled: enabled));
  }

  Future<void> toggleDailyReminder(bool enabled) async {
    await _settingsRepository.setDailyReminderEnabled(enabled);
    emit(state.copyWith(isDailyReminderEnabled: enabled));
  }

  AppAppearance _mapStringToAppearance(String? value) {
    if (value == null) return AppAppearance.system;
    return AppAppearance.values.firstWhere(
          (e) => e.name == value,
      orElse: () => AppAppearance.system,
    );
  }
}
