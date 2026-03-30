import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/parsing/api_response_parser.dart';
import '../../domain/entities/comment.dart';
import '../models/comment_model.dart';

class CommentRemoteDataSource {
  const CommentRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Comment>> watchComments(String taskId) {
    // Day 37 parser factory usage: comment Firestore payloads are parsed by response type.
    final parser = ApiResponseParserFactory.create<CommentModel>(
      ApiResponseType.comment,
    );
    return _firestore
        .collection('tasks')
        .doc(taskId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => parser.parse(
                  ApiResponseContext(data: doc.data(), id: doc.id),
                ),
              )
              .toList(),
        );
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
      debugPrint('[comment_datasource] addComment failed: $e\n$stackTrace');
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
