import 'comment.dart';

class CommentsState {
  const CommentsState({
    this.comments = const <Comment>[],
    this.isLoading = false,
    this.errorMessage,
    this.isPosting = false,
  });

  static const Object _unset = Object();

  final List<Comment> comments;
  final bool isLoading;
  final String? errorMessage;
  final bool isPosting;

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? isPosting,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      isPosting: isPosting ?? this.isPosting,
    );
  }
}
