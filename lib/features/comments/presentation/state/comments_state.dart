import '../../domain/entities/comment.dart';

class CommentsState {
  const CommentsState({
    this.items = const [],
    this.isLoading = false,
    this.isPosting = false,
    this.errorMessage,
  });

  final List<Comment> items;
  final bool isLoading;
  final bool isPosting;
  final String? errorMessage;

  CommentsState copyWith({
    List<Comment>? items,
    bool? isLoading,
    bool? isPosting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isPosting: isPosting ?? this.isPosting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
