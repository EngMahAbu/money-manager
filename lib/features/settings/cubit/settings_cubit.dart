import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void updateCurrency(String currency) {
    emit(state.copyWith(currency: currency));
  }

  void updateAppearance(AppAppearance appearance) {
    emit(state.copyWith(appearance: appearance));
  }

  void toggleAppLock(bool enabled) {
    emit(state.copyWith(isAppLockEnabled: enabled));
  }

  void toggleDailyReminder(bool enabled) {
    emit(state.copyWith(isDailyReminderEnabled: enabled));
  }
}
