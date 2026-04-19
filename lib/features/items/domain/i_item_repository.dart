import 'item.dart';

abstract class IItemRepository {
  Future<List<Item>> fetchItems({required String userId});

  Future<Item> addItem({required String userId, required String title});

  Future<Item> updateItemStatus({
    required String userId,
    required String itemId,
    required String status,
  });
}
