import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error_handler.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/i_item_repository.dart';
import '../../domain/item.dart';
import '../state/items_state.dart';

class ItemsController extends ChangeNotifier {
  ItemsController({
    required IItemRepository itemRepository,
    required IAuthRepository authRepository,
    required AppErrorHandler errorHandler,
  }) : _itemRepository = itemRepository,
       _authRepository = authRepository,
       _errorHandler = errorHandler;

  final IItemRepository _itemRepository;
  final IAuthRepository _authRepository;
  final AppErrorHandler _errorHandler;

  ItemsState _state = const ItemsState();

  ItemsState get state => _state;

  void _emit(ItemsState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> loadItems() async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Sign in first to load items.'));
      return;
    }

    _emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final items = await _itemRepository.fetchItems(userId: userId);
      _emit(state.copyWith(items: items, isLoading: false, errorMessage: null));
    } catch (error) {
      _emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _errorHandler.toMessage(error),
        ),
      );
    }
  }

  Future<void> addItem(String title) async {
    final userId = _authRepository.currentUser?.uid;
    final safeTitle = title.trim();
    if (userId == null || userId.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Sign in first to add items.'));
      return;
    }
    if (safeTitle.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Enter an item title.'));
      return;
    }

    _emit(state.copyWith(isAdding: true, errorMessage: null));
    try {
      final created = await _itemRepository.addItem(
        userId: userId,
        title: safeTitle,
      );
      final updatedItems = <Item>[created, ...state.items];
      _emit(
        state.copyWith(
          isAdding: false,
          errorMessage: null,
          items: updatedItems,
        ),
      );
    } catch (error) {
      _emit(
        state.copyWith(
          isAdding: false,
          errorMessage: _errorHandler.toMessage(error),
        ),
      );
    }
  }

  Future<void> updateItemStatus({
    required String itemId,
    required String status,
  }) async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Sign in first to update tasks.'));
      return;
    }

    try {
      final updated = await _itemRepository.updateItemStatus(
        userId: userId,
        itemId: itemId,
        status: status,
      );
      final updatedItems = state.items
          .map((item) => item.id == itemId ? updated : item)
          .toList(growable: false);
      _emit(state.copyWith(items: updatedItems, errorMessage: null));
    } catch (error) {
      _emit(state.copyWith(errorMessage: _errorHandler.toMessage(error)));
    }
  }
}
