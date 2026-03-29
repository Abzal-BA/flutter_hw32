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
    return NotificationPayload(
      source: source,
      title: message.notification?.title ?? message.data['title']?.toString(),
      body: message.notification?.body ?? message.data['body']?.toString(),
      data: Map<String, dynamic>.from(message.data),
    );
  }

  factory NotificationPayload.fromJsonString(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const NotificationPayload(
            source: 'local', data: <String, dynamic>{});
      }

      return NotificationPayload(
        source: (decoded['source'] ?? 'local').toString(),
        title: decoded['title']?.toString(),
        body: decoded['body']?.toString(),
        data: Map<String, dynamic>.from(
          (decoded['data'] as Map?) ?? const <String, dynamic>{},
        ),
      );
    } catch (_) {
      return const NotificationPayload(
          source: 'local', data: <String, dynamic>{});
    }
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
