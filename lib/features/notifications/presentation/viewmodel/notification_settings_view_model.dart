import 'package:flutter/foundation.dart';

import '../../notification_service.dart';

class NotificationSettingsViewModel extends ChangeNotifier {
  NotificationSettingsViewModel(this._notificationService) {
    _notificationService.notificationsEnabled.addListener(notifyListeners);
  }

  final NotificationService _notificationService;

  bool get notificationsEnabled => _notificationService.notificationsEnabled.value;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _notificationService.setNotificationsEnabled(enabled);
  }

  Future<void> sendSimpleTest() async {
    await _notificationService.sendTestNotification();
  }

  Future<void> sendDeepLinkTest(String itemId) async {
    await _notificationService.sendTestNotification(itemId: itemId);
  }

  @override
  void dispose() {
    _notificationService.notificationsEnabled.removeListener(notifyListeners);
    super.dispose();
  }
}