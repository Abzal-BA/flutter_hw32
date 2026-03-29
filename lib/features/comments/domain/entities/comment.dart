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
}
