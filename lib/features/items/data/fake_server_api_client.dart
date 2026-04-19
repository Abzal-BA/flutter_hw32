import 'dart:async';

import 'api_client.dart';

class FakeServerApiClient implements ApiClient {
  FakeServerApiClient({
    List<Map<String, dynamic>>? seedItems,
    this.latency = const Duration(milliseconds: 50),
  }) : _items = List<Map<String, dynamic>>.from(
         seedItems ??
             <Map<String, dynamic>>[
               <String, dynamic>{
                 'id': 'item-1',
                 'title': 'Read CI guide',
                 'status': 'todo',
                 'createdAt': '2026-04-18T09:00:00.000Z',
               },
               <String, dynamic>{
                 'id': 'item-2',
                 'title': 'Prepare day 41 homework',
                 'status': 'in_progress',
                 'createdAt': '2026-04-18T10:00:00.000Z',
               },
             ],
       );

  final Duration latency;
  final List<Map<String, dynamic>> _items;

  int fetchCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchItems({
    required String userId,
  }) async {
    fetchCalls += 1;
    await Future<void>.delayed(latency);
    return _items
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  @override
  Future<Map<String, dynamic>> createItem({
    required String userId,
    required Map<String, dynamic> payload,
  }) async {
    createCalls += 1;
    await Future<void>.delayed(latency);
    final created = <String, dynamic>{
      'id': 'item-${_items.length + 1}',
      'title': (payload['title'] ?? '').toString(),
      'status': 'todo',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    _items.add(created);
    return Map<String, dynamic>.from(created);
  }

  @override
  Future<Map<String, dynamic>> updateItem({
    required String userId,
    required String itemId,
    required Map<String, dynamic> payload,
  }) async {
    updateCalls += 1;
    await Future<void>.delayed(latency);

    final index = _items.indexWhere((item) => item['id'] == itemId);
    if (index == -1) {
      throw Exception('Task not found.');
    }

    final updated = <String, dynamic>{..._items[index], ...payload};
    _items[index] = updated;
    return Map<String, dynamic>.from(updated);
  }
}
