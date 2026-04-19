import '../../items/domain/i_item_repository.dart';
import '../../items/domain/item.dart';
import 'api_client.dart';
import 'items_db.dart';

class ItemRepositoryImpl implements IItemRepository {
  const ItemRepositoryImpl({required ApiClient apiClient, required ItemsDb db})
    : _apiClient = apiClient,
      _db = db;

  final ApiClient _apiClient;
  final ItemsDb _db;

  @override
  Future<Item> addItem({required String userId, required String title}) async {
    final json = await _apiClient.createItem(
      userId: userId,
      payload: <String, dynamic>{'title': title},
    );
    await _db.insertItem(userId: userId, item: json);
    return _mapItem(json);
  }

  @override
  Future<Item> updateItemStatus({
    required String userId,
    required String itemId,
    required String status,
  }) async {
    final json = await _apiClient.updateItem(
      userId: userId,
      itemId: itemId,
      payload: <String, dynamic>{'status': status},
    );
    await _db.updateItem(userId: userId, itemId: itemId, item: json);
    return _mapItem(json);
  }

  @override
  Future<List<Item>> fetchItems({required String userId}) async {
    try {
      final json = await _apiClient.fetchItems(userId: userId);
      await _db.saveItems(userId: userId, items: json);
      return json.map(_mapItem).toList(growable: false);
    } catch (_) {
      final cached = await _db.readItems(userId: userId);
      return cached.map(_mapItem).toList(growable: false);
    }
  }

  Item _mapItem(Map<String, dynamic> json) {
    return Item(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? 'todo').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
