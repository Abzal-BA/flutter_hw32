import 'task_item.dart';

class NotesState {
  const NotesState({
    this.items = const <TaskItem>[],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.errorMessage,
    this.limit = 10,
    this.searchTag = '',
    this.statusFilter = 'all',
    this.categoryFilter = 'all',
    this.hasMore = true,
  });

  static const Object _unset = Object();

  final List<TaskItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int limit;
  final String searchTag;
  final String statusFilter;
  final String categoryFilter;
  final bool hasMore;

  NotesState copyWith({
    List<TaskItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _unset,
    int? limit,
    String? searchTag,
    String? statusFilter,
    String? categoryFilter,
    bool? hasMore,
  }) {
    return NotesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      limit: limit ?? this.limit,
      searchTag: searchTag ?? this.searchTag,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
