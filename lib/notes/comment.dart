import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  const Comment({
    required this.id,
    required this.taskId,
    required this.uid,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String uid;
  final String userName;
  final String text;
  final DateTime createdAt;

  factory Comment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdTimestamp = data['createdAt'];

    return Comment(
      id: doc.id,
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
