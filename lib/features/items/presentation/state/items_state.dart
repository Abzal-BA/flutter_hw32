import '../../domain/item.dart';

class ItemsState {
  const ItemsState({
    this.items = const <Item>[],
    this.isLoading = false,
    this.isAdding = false,
    this.errorMessage,
  });

  static const Object _unset = Object();

  final List<Item> items;
  final bool isLoading;
  final bool isAdding;
  final String? errorMessage;

  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    bool? isAdding,
    Object? errorMessage = _unset,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isAdding: isAdding ?? this.isAdding,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
