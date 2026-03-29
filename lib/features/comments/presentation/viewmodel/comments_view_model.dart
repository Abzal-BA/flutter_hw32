import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error_handler.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/watch_comments_usecase.dart';
import '../state/comments_state.dart';

class CommentsViewModel extends ChangeNotifier {
  CommentsViewModel({
    required String taskId,
    required WatchCommentsUseCase watchCommentsUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
    required IAuthRepository authRepository,
    required AppErrorHandler errorHandler,
  })  : _taskId = taskId,
        _watchCommentsUseCase = watchCommentsUseCase,
        _addCommentUseCase = addCommentUseCase,
        _deleteCommentUseCase = deleteCommentUseCase,
        _authRepository = authRepository,
        _errorHandler = errorHandler {
    _subscribe();
  }

  final String _taskId;
  final WatchCommentsUseCase _watchCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;
  final IAuthRepository _authRepository;
  final AppErrorHandler _errorHandler;

  CommentsState _state = const CommentsState(isLoading: true);
  CommentsState get state => _state;

  StreamSubscription<List<Comment>>? _commentsSub;

  void _subscribe() {
    _commentsSub = _watchCommentsUseCase.call(_taskId).listen(
      (comments) {
        _state = _state.copyWith(
          items: List.unmodifiable(comments),
          isLoading: false,
          clearError: true,
        );
        notifyListeners();
      },
      onError: (Object error) {
        _state = _state.copyWith(
          isLoading: false,
          errorMessage:
              'Failed to load comments: ${_errorHandler.toMessage(error)}',
        );
        notifyListeners();
      },
    );
  }

  Future<bool> addComment(String text) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      _state = _state.copyWith(errorMessage: 'You must be logged in.');
      notifyListeners();
      return false;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Comment cannot be empty.');
      notifyListeners();
      return false;
    }

    _state = _state.copyWith(isPosting: true, clearError: true);
    notifyListeners();

    try {
      await _addCommentUseCase.call(AddCommentParams(
        taskId: _taskId,
        uid: user.uid,
        userName: user.displayName ?? user.email ?? 'Anonymous',
        text: trimmed,
      ));
      _state = _state.copyWith(isPosting: false, clearError: true);
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(
        isPosting: false,
        errorMessage:
            'Failed to add comment: ${_errorHandler.toMessage(error)}',
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _deleteCommentUseCase.call(
        taskId: _taskId,
        commentId: commentId,
      );
      _state = _state.copyWith(clearError: true);
    } catch (error) {
      _state = _state.copyWith(
        errorMessage:
            'Failed to delete comment: ${_errorHandler.toMessage(error)}',
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _commentsSub?.cancel();
    super.dispose();
  }
}