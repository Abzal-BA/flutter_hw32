import '../entities/comment.dart';

abstract class ICommentRepository {
  Stream<List<Comment>> watchComments(String taskId);

  Future<void> addComment({
    required String taskId,
    required String uid,
    required String userName,
    required String text,
  });

  Future<void> deleteComment({
    required String taskId,
    required String commentId,
  });
}
