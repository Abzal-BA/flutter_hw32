import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPayload {
  const NotificationPayload({
    required this.source,
    required this.data,
    this.title,
    this.body,
  });

  final String source;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  String? get itemId {
    final value = data['itemId'] ?? data['item_id'] ?? data['id'];
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  factory NotificationPayload.fromRemoteMessage(
    RemoteMessage message, {
    required String source,
  }) {
    return NotificationPayload.fromMap(<String, dynamic>{
      'source': source,
      'title': message.notification?.title ?? message.data['title'],
      'body': message.notification?.body ?? message.data['body'],
      'data': message.data,
    }, fallbackSource: source);
  }

  factory NotificationPayload.fromJsonString(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const NotificationPayload(
          source: 'local',
          data: <String, dynamic>{},
        );
      }

      return NotificationPayload.fromMap(decoded, fallbackSource: 'local');
    } catch (_) {
      return const NotificationPayload(
        source: 'local',
        data: <String, dynamic>{},
      );
    }
  }

  factory NotificationPayload.fromMap(
    Map<String, dynamic> raw, {
    required String fallbackSource,
  }) {
    return NotificationPayload(
      source: (raw['source'] ?? fallbackSource).toString(),
      title: raw['title']?.toString(),
      body: raw['body']?.toString(),
      data: Map<String, dynamic>.from(
        (raw['data'] as Map?) ?? const <String, dynamic>{},
      ),
    );
  }

  String toJsonString() {
    return jsonEncode(<String, dynamic>{
      'source': source,
      'title': title,
      'body': body,
      'data': data,
    });
  }
}
