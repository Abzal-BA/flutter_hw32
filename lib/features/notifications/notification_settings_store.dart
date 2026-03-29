import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsStore {
  NotificationSettingsStore(this._prefs);

  static const String notificationsEnabledKey = 'notifications_enabled';
  final SharedPreferences _prefs;

  bool get isEnabled => _prefs.getBool(notificationsEnabledKey) ?? true;

  Future<void> setEnabled(bool value) async {
    await _prefs.setBool(notificationsEnabledKey, value);
  }
}
