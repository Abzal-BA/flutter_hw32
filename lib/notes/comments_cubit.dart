import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'comment.dart';
import 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required this.taskId,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth,
        super(const CommentsState());

  final String taskId;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _commentsSub;

  Future<void> startListening() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    _commentsSub?.cancel();

    _commentsSub = _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final items = snapshot.docs.map(Comment.fromDoc).toList();
            emit(state.copyWith(comments: items, isLoading: false));
          },
          onError: (Object error) {
            emit(state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to load comments: $error',
            ));
          },
        );
  }

  Future<void> addComment(String text) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(errorMessage: 'You must be logged in.'));
      return;
    }

    final safeText = text.trim();
    if (safeText.isEmpty) {
      emit(state.copyWith(errorMessage: 'Comment cannot be empty.'));
      return;
    }

    emit(state.copyWith(isPosting: true, errorMessage: null));

    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .add(<String, dynamic>{
        'taskId': taskId,
        'uid': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'text': safeText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(state.copyWith(isPosting: false));
    } catch (error) {
      emit(state.copyWith(
        isPosting: false,
        errorMessage: 'Failed to add comment: $error',
      ));
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
      emit(state.copyWith(errorMessage: 'Failed to delete comment: $error'));
    }
  }

  @override
  Future<void> close() async {
    await _commentsSub?.cancel();
    return super.close();
  }
}
