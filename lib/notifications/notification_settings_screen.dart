import 'package:flutter/material.dart';

import '../di/service_locator.dart';
import 'notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = getIt<NotificationService>();
  final TextEditingController _itemIdController = TextEditingController();

  @override
  void dispose() {
    _itemIdController.dispose();
    super.dispose();
  }

  Future<void> _sendSimpleTest() async {
    await _notificationService.sendTestNotification();
  }

  Future<void> _sendDeepLinkTest() async {
    final itemId = _itemIdController.text.trim();
    if (itemId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter item id first.')),
      );
      return;
    }

    await _notificationService.sendTestNotification(itemId: itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _notificationService.notificationsEnabled,
            builder: (context, enabled, _) {
              return SwitchListTile(
                value: enabled,
                title: const Text('Enable local notification display'),
                subtitle: const Text('This flag is stored locally on device.'),
                onChanged: _notificationService.setNotificationsEnabled,
              );
            },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sendSimpleTest,
            icon: const Icon(Icons.notification_important),
            label: const Text('Send test notification'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _itemIdController,
            decoration: const InputDecoration(
              labelText: 'Deep link item id',
              hintText: 'Paste Firestore task document id',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _sendDeepLinkTest,
            icon: const Icon(Icons.link),
            label: const Text('Send deep link test notification'),
          ),
        ],
      ),
    );
  }
}