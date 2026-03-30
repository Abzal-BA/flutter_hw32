import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/services/analytics_service.dart';
import '../tasks/presentation/pages/task_details_screen.dart';
import 'notification_payload.dart';
import 'notification_settings_store.dart';
import 'presentation/pages/notification_details_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[notif][receive_background] id=${message.messageId} data=${message.data}',
  );
}

class NotificationService {
  NotificationService({
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required NotificationSettingsStore settingsStore,
  }) : _messaging = messaging,
       _localNotifications = localNotifications,
       _auth = auth,
       _firestore = firestore,
       _settingsStore = settingsStore {
    notificationsEnabled.value = _settingsStore.isEnabled;
  }

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final NotificationSettingsStore _settingsStore;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ValueNotifier<bool> notificationsEnabled = ValueNotifier<bool>(true);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'day34_channel',
    'Day 34 Notifications',
    description: 'General notification channel',
    importance: Importance.high,
  );

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openSub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<User?>? _authSub;

  NotificationPayload? _pendingPayload;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _configureLocalNotifications();
    await _requestPermission();
    await _syncCurrentToken();

    _foregroundSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload = NotificationPayload.fromRemoteMessage(
        message,
        source: 'opened_remote',
      );
      _log('open_remote', payload: payload);
      _navigateFromPayload(payload);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final payload = NotificationPayload.fromRemoteMessage(
        initialMessage,
        source: 'opened_initial_message',
      );
      _log('open_initial_remote', payload: payload);
      _navigateFromPayload(payload);
    }

    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      _log(
        'token_refresh',
        extra: <String, Object?>{'tokenLength': token.length},
      );
      await _saveTokenForCurrentUser(token);
    });

    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _syncCurrentToken();
      }
    });
  }

  Future<void> _configureLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: (details) {
        final rawPayload = details.payload;
        final payload = NotificationPayload.fromJsonString(rawPayload ?? '{}');
        _log('open_local', payload: payload);
        _navigateFromPayload(payload);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _log(
      'permission',
      extra: <String, Object?>{
        'authorizationStatus': settings.authorizationStatus.name,
      },
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final payload = NotificationPayload.fromRemoteMessage(
      message,
      source: 'received_foreground',
    );

    _log('receive_foreground', payload: payload);

    if (!notificationsEnabled.value) {
      _log('foreground_skipped_disabled', payload: payload);
      return;
    }

    await _showLocalNotification(payload);
  }

  Future<void> _showLocalNotification(NotificationPayload payload) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _localNotifications.show(
      id,
      payload.title ?? 'Notification',
      payload.body ?? 'Open to view details',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
      payload: payload.toJsonString(),
    );

    _log('local_shown', payload: payload);
  }

  Future<void> sendTestNotification({String? itemId}) async {
    final data = <String, dynamic>{
      'sentAt': DateTime.now().toIso8601String(),
      'type': 'local_test',
    };
    if ((itemId ?? '').trim().isNotEmpty) {
      data['itemId'] = itemId!.trim();
    }

    final payload = NotificationPayload(
      source: 'local_test',
      title: 'Test Notification',
      body: (itemId ?? '').trim().isEmpty
          ? 'Tap to open Notification Details'
          : 'Tap to open item ${itemId!.trim()}',
      data: data,
    );

    await _showLocalNotification(payload);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _settingsStore.setEnabled(enabled);
    _log('settings_updated', extra: <String, Object?>{'enabled': enabled});
  }

  Future<void> _syncCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await _saveTokenForCurrentUser(token);
    } on FirebaseException catch (error, stackTrace) {
      if (error.code == 'apns-token-not-set') {
        _log('token_skipped_apns_pending');
        return;
      }

      _log(
        'token_sync_failed',
        extra: <String, Object?>{'code': error.code, 'message': error.message},
      );
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      _log(
        'token_sync_failed',
        extra: <String, Object?>{'error': error.toString()},
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _saveTokenForCurrentUser(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return;
    }

    await _firestore.collection('users').doc(uid).set(<String, dynamic>{
      'deviceToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
      'tokenPlatform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    }, SetOptions(merge: true));

    _log(
      'token_saved',
      extra: <String, Object?>{'uid': uid, 'tokenLength': token.length},
    );
  }

  void _navigateFromPayload(NotificationPayload payload) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      _pendingPayload = payload;
      return;
    }

    final itemId = payload.itemId;
    if (itemId != null && itemId.isNotEmpty) {
      nav.push(
        MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: itemId)),
      );
      return;
    }

    nav.push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailsScreen(payload: payload),
      ),
    );
  }

  void flushPendingNavigation() {
    final payload = _pendingPayload;
    if (payload == null) {
      return;
    }
    _pendingPayload = null;
    _navigateFromPayload(payload);
  }

  void _log(
    String event, {
    NotificationPayload? payload,
    Map<String, Object?> extra = const <String, Object?>{},
  }) {
    AnalyticsService.instance.log(
      event,
      scope: 'NotificationService',
      payload: <String, Object?>{
        'source': payload?.source,
        'title': payload?.title,
        'body': payload?.body,
        'itemId': payload?.itemId,
        'data': payload?.data,
        ...extra,
      },
    );
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openSub?.cancel();
    await _tokenRefreshSub?.cancel();
    await _authSub?.cancel();
  }
}
