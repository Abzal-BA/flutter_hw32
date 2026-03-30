import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hw32/core/services/analytics_service.dart';

void main() {
  setUp(() {
    AnalyticsService.resetForTest();
  });

  // Day 37 test: proves the singleton instance is reused.
  test('singleton returns the same instance every time', () {
    final first = AnalyticsService.instance;
    final second = AnalyticsService.instance;
    final third = AnalyticsService();

    expect(identical(first, second), isTrue);
    expect(identical(second, third), isTrue);
  });

  // Day 37 test: proves the singleton constructor is not executed repeatedly.
  test('singleton internal constructor is not executed repeatedly', () {
    AnalyticsService.instance;
    AnalyticsService.instance;
    AnalyticsService();

    expect(AnalyticsService.instanceCount, 1);
  });

  // Day 37 test: proves shared state is visible through all singleton references.
  test('singleton shares state across references', () {
    final first = AnalyticsService.instance;
    final second = AnalyticsService.instance;

    first.log(
      'task_opened',
      scope: 'test',
      payload: const <String, Object?>{'id': '42'},
    );

    expect(second.events, hasLength(1));
    expect(second.events.single.name, 'task_opened');
    expect(second.events.single.scope, 'test');
  });
}
