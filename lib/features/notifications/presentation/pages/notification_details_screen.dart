import 'package:flutter/material.dart';

import '../../notification_payload.dart';

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({required this.payload, super.key});

  final NotificationPayload payload;

  @override
  Widget build(BuildContext context) {
    final entries = payload.data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Source: ${payload.source}'),
          const SizedBox(height: 8),
          Text('Title: ${payload.title ?? '-'}'),
          const SizedBox(height: 8),
          Text('Body: ${payload.body ?? '-'}'),
          const SizedBox(height: 16),
          if (entries.isEmpty) const Text('No payload data.'),
          if (entries.isNotEmpty)
            ...entries.map(
              (entry) => Card(
                child: ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value.toString()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
