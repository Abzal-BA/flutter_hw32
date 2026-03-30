import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.taskId,
    required super.uid,
    required super.userName,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CommentModel.fromMap(doc.data() ?? <String, dynamic>{}, id: doc.id);
  }

  factory CommentModel.fromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    final createdTimestamp = data['createdAt'];

    return CommentModel(
      id: id,
      taskId: (data['taskId'] ?? '').toString(),
      uid: (data['uid'] ?? '').toString(),
      userName: (data['userName'] ?? 'Unknown').toString(),
      text: (data['text'] ?? '').toString(),
      createdAt: createdTimestamp is Timestamp
          ? createdTimestamp.toDate()
          : DateTime.now(),
    );
  }
}
