import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hw32/features/items/data/api_client.dart';
import 'package:flutter_hw32/features/items/data/item_repository_impl.dart';
import 'package:flutter_hw32/features/items/data/items_db.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockItemsDb extends Mock implements ItemsDb {}

void main() {
  late _MockApiClient apiClient;
  late _MockItemsDb db;
  late ItemRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  setUp(() {
    apiClient = _MockApiClient();
    db = _MockItemsDb();
    repository = ItemRepositoryImpl(apiClient: apiClient, db: db);
  });

  test('fetches items from api and stores them in db', () async {
    final json = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'item-1',
        'title': 'Remote item',
        'status': 'todo',
        'createdAt': '2026-04-18T09:00:00.000Z',
      },
    ];
    when(
      () => apiClient.fetchItems(userId: 'user-1'),
    ).thenAnswer((_) async => json);
    when(
      () => db.saveItems(userId: 'user-1', items: json),
    ).thenAnswer((_) async {});

    final items = await repository.fetchItems(userId: 'user-1');

    expect(items, hasLength(1));
    expect(items.first.title, 'Remote item');
    expect(items.first.status, 'todo');
    verify(() => apiClient.fetchItems(userId: 'user-1')).called(1);
    verify(() => db.saveItems(userId: 'user-1', items: json)).called(1);
    verifyNever(() => db.readItems(userId: any(named: 'userId')));
  });

  test('falls back to cached items when api fails', () async {
    final cached = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'item-9',
        'title': 'Cached item',
        'status': 'done',
        'createdAt': '2026-04-18T09:30:00.000Z',
      },
    ];
    when(
      () => apiClient.fetchItems(userId: 'user-1'),
    ).thenThrow(Exception('network disabled'));
    when(() => db.readItems(userId: 'user-1')).thenAnswer((_) async => cached);

    final items = await repository.fetchItems(userId: 'user-1');

    expect(items.single.title, 'Cached item');
    expect(items.single.status, 'done');
    verify(() => apiClient.fetchItems(userId: 'user-1')).called(1);
    verify(() => db.readItems(userId: 'user-1')).called(1);
    verifyNever(
      () => db.saveItems(
        userId: any(named: 'userId'),
        items: any(named: 'items'),
      ),
    );
  });

  test('creates item through api and writes it to db', () async {
    final createdJson = <String, dynamic>{
      'id': 'item-2',
      'title': 'New item',
      'status': 'todo',
      'createdAt': '2026-04-18T10:00:00.000Z',
    };
    when(
      () => apiClient.createItem(
        userId: 'user-1',
        payload: <String, dynamic>{'title': 'New item'},
      ),
    ).thenAnswer((_) async => createdJson);
    when(
      () => db.insertItem(userId: 'user-1', item: createdJson),
    ).thenAnswer((_) async {});

    final item = await repository.addItem(userId: 'user-1', title: 'New item');

    expect(item.id, 'item-2');
    expect(item.title, 'New item');
    expect(item.status, 'todo');
    verify(
      () => apiClient.createItem(
        userId: 'user-1',
        payload: <String, dynamic>{'title': 'New item'},
      ),
    ).called(1);
    verify(() => db.insertItem(userId: 'user-1', item: createdJson)).called(1);
  });

  test('updates item status through api and writes it to db', () async {
    final updatedJson = <String, dynamic>{
      'id': 'item-2',
      'title': 'New item',
      'status': 'done',
      'createdAt': '2026-04-18T10:00:00.000Z',
    };
    when(
      () => apiClient.updateItem(
        userId: 'user-1',
        itemId: 'item-2',
        payload: <String, dynamic>{'status': 'done'},
      ),
    ).thenAnswer((_) async => updatedJson);
    when(
      () =>
          db.updateItem(userId: 'user-1', itemId: 'item-2', item: updatedJson),
    ).thenAnswer((_) async {});

    final item = await repository.updateItemStatus(
      userId: 'user-1',
      itemId: 'item-2',
      status: 'done',
    );

    expect(item.status, 'done');
    verify(
      () => apiClient.updateItem(
        userId: 'user-1',
        itemId: 'item-2',
        payload: <String, dynamic>{'status': 'done'},
      ),
    ).called(1);
    verify(
      () =>
          db.updateItem(userId: 'user-1', itemId: 'item-2', item: updatedJson),
    ).called(1);
  });
}
