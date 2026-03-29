import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/comment.dart';
import '../models/comment_model.dart';

class CommentRemoteDataSource {
  const CommentRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Comment>> watchComments(String taskId) {
    return _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CommentModel.fromDoc).toList());
  }

  Future<void> addComment({
    required String taskId,
    required String uid,
    required String userName,
    required String text,
  }) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .add(<String, dynamic>{
        'taskId': taskId,
        'uid': uid,
        'userName': userName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      debugPrint(
          '[comment_datasource] addComment failed: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String taskId,
    required String commentId,
  }) {
    return _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}
