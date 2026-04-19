abstract class ItemsDb {
  Future<List<Map<String, dynamic>>> readItems({required String userId});

  Future<void> saveItems({
    required String userId,
    required List<Map<String, dynamic>> items,
  });

  Future<void> insertItem({
    required String userId,
    required Map<String, dynamic> item,
  });

  Future<void> updateItem({
    required String userId,
    required String itemId,
    required Map<String, dynamic> item,
  });
}
