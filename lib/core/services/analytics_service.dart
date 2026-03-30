import 'package:flutter/foundation.dart';

class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    required this.scope,
    required this.timestamp,
    this.payload = const <String, Object?>{},
  });

  final String name;
  final String scope;
  final DateTime timestamp;
  final Map<String, Object?> payload;
}

class AnalyticsService {
  AnalyticsService._internal() {
    _instanceCount++;
  }

  static AnalyticsService? _instance;
  static int _instanceCount = 0;

  final List<AnalyticsEvent> _events = <AnalyticsEvent>[];

  factory AnalyticsService() {
    return _instance ??= AnalyticsService._internal();
  }

  static AnalyticsService get instance => AnalyticsService();

  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  void log(
    String name, {
    required String scope,
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    final event = AnalyticsEvent(
      name: name,
      scope: scope,
      timestamp: DateTime.now(),
      payload: payload,
    );
    _events.add(event);

    debugPrint(
      '[analytics][${event.timestamp.toIso8601String()}][$scope] $name payload=$payload',
    );
  }

  @visibleForTesting
  static int get instanceCount => _instanceCount;

  @visibleForTesting
  static void resetForTest() {
    _instance = null;
    _instanceCount = 0;
  }
}
