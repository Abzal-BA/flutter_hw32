import 'items_db.dart';

class InMemoryItemsDb implements ItemsDb {
  final Map<String, List<Map<String, dynamic>>> _storage =
      <String, List<Map<String, dynamic>>>{};

  @override
  Future<void> insertItem({
    required String userId,
    required Map<String, dynamic> item,
  }) async {
    final current = _storage[userId] ?? <Map<String, dynamic>>[];
    _storage[userId] = <Map<String, dynamic>>[
      ...current.map((entry) => Map<String, dynamic>.from(entry)),
      Map<String, dynamic>.from(item),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> readItems({required String userId}) async {
    final current = _storage[userId] ?? <Map<String, dynamic>>[];
    return current
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList(growable: false);
  }

  @override
  Future<void> saveItems({
    required String userId,
    required List<Map<String, dynamic>> items,
  }) async {
    _storage[userId] = items
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList(growable: false);
  }

  @override
  Future<void> updateItem({
    required String userId,
    required String itemId,
    required Map<String, dynamic> item,
  }) async {
    final current = _storage[userId] ?? <Map<String, dynamic>>[];
    _storage[userId] = current
        .map(
          (entry) => entry['id'] == itemId
              ? Map<String, dynamic>.from(item)
              : Map<String, dynamic>.from(entry),
        )
        .toList(growable: false);
  }
}
