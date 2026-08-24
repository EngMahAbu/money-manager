import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const String _keyDefaultCurrency = 'default_currency';
  static const String _keyAppearance = 'appearance';
  static const String _keyAppLock = 'app_lock';
  static const String _keyDailyReminder = 'daily_reminder';

  String getDefaultCurrency() {
    return _prefs.getString(_keyDefaultCurrency) ?? 'USD';
  }

  Future<void> setDefaultCurrency(String currency) async {
    await _prefs.setString(_keyDefaultCurrency, currency);
  }

  String? getAppearance() {
    return _prefs.getString(_keyAppearance);
  }

  Future<void> setAppearance(String appearance) async {
    await _prefs.setString(_keyAppearance, appearance);
  }

  bool getAppLockEnabled() {
    return _prefs.getBool(_keyAppLock) ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _prefs.setBool(_keyAppLock, enabled);
  }

  bool getDailyReminderEnabled() {
    return _prefs.getBool(_keyDailyReminder) ?? false;
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    await _prefs.setBool(_keyDailyReminder, enabled);
  }
}
