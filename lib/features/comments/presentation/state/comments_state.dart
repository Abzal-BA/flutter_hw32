import '../../domain/entities/comment.dart';

class CommentsState {
  const CommentsState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Comment> items;
  final bool isLoading;
  final String? errorMessage;

  CommentsState copyWith({
    List<Comment>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
