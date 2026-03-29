import 'task_item.dart';

class NotesViewState {
  const NotesViewState({
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

  final List<TaskItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int limit;
  final String searchTag;
  final String statusFilter;
  final String categoryFilter;
  final bool hasMore;

  NotesViewState copyWith({
    List<TaskItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    int? limit,
    String? searchTag,
    String? statusFilter,
    String? categoryFilter,
    bool? hasMore,
  }) {
    return NotesViewState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      limit: limit ?? this.limit,
      searchTag: searchTag ?? this.searchTag,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
