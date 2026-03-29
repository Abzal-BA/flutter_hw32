import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/error_handler.dart';
import 'comment.dart';
import 'comments_state.dart';

class CommentsController extends ChangeNotifier {
  CommentsController({
    required this.taskId,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required AppErrorHandler errorHandler,
  })  : _firestore = firestore,
        _auth = auth,
        _errorHandler = errorHandler;

  final String taskId;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AppErrorHandler _errorHandler;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _commentsSub;

  CommentsState _state = const CommentsState();
  CommentsState get state => _state;

  void _setState(CommentsState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> startListening() async {
    _setState(state.copyWith(isLoading: true, errorMessage: null));

    await _commentsSub?.cancel();

    _commentsSub = _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final items = snapshot.docs.map(Comment.fromDoc).toList();
            _setState(state.copyWith(comments: items, isLoading: false));
          },
          onError: (Object error) {
            _setState(
              state.copyWith(
                isLoading: false,
                errorMessage:
                    'Failed to load comments: ${_errorHandler.toMessage(error)}',
              ),
            );
          },
        );
  }

  Future<void> addComment(String text) async {
    final user = _auth.currentUser;
    if (user == null) {
      _setState(state.copyWith(errorMessage: 'You must be logged in.'));
      return;
    }

    final safeText = text.trim();
    if (safeText.isEmpty) {
      _setState(state.copyWith(errorMessage: 'Comment cannot be empty.'));
      return;
    }

    _setState(state.copyWith(isPosting: true, errorMessage: null));

    try {
      await _firestore.collection('tasks').doc(taskId).collection('comments').add(
        <String, dynamic>{
          'taskId': taskId,
          'uid': user.uid,
          'userName': user.displayName ?? 'Anonymous',
          'text': safeText,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      _setState(state.copyWith(isPosting: false));
    } catch (error) {
      _setState(
        state.copyWith(
          isPosting: false,
          errorMessage: 'Failed to add comment: ${_errorHandler.toMessage(error)}',
        ),
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (error) {
      _setState(
        state.copyWith(
          errorMessage: 'Failed to delete comment: ${_errorHandler.toMessage(error)}',
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentsSub?.cancel();
    super.dispose();
  }
}
