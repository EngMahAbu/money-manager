import 'package:equatable/equatable.dart';

enum AppAppearance { system, light, dark }

class SettingsState extends Equatable {
  final String currency;
  final AppAppearance appearance;
  final bool isAppLockEnabled;
  final bool isDailyReminderEnabled;

  const SettingsState({
    this.currency = 'USD',
    this.appearance = AppAppearance.system,
    this.isAppLockEnabled = false,
    this.isDailyReminderEnabled = false,
  });

  SettingsState copyWith({
    String? currency,
    AppAppearance? appearance,
    bool? isAppLockEnabled,
    bool? isDailyReminderEnabled,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
      appearance: appearance ?? this.appearance,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      isDailyReminderEnabled: isDailyReminderEnabled ?? this.isDailyReminderEnabled,
    );
  }

  @override
  List<Object?> get props => [
        currency,
        appearance,
        isAppLockEnabled,
        isDailyReminderEnabled,
      ];
}
