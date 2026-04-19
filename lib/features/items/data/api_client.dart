abstract class ApiClient {
  Future<List<Map<String, dynamic>>> fetchItems({required String userId});

  Future<Map<String, dynamic>> createItem({
    required String userId,
    required Map<String, dynamic> payload,
  });

  Future<Map<String, dynamic>> updateItem({
    required String userId,
    required String itemId,
    required Map<String, dynamic> payload,
  });
}
