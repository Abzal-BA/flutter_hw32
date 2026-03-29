import '../../domain/entities/comment.dart';
import '../../domain/repositories/i_comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

class CommentRepositoryImpl implements ICommentRepository {
  const CommentRepositoryImpl(this._dataSource);

  final CommentRemoteDataSource _dataSource;

  @override
  Stream<List<Comment>> watchComments(String taskId) =>
      _dataSource.watchComments(taskId);

  @override
  Future<void> addComment({
    required String taskId,
    required String uid,
    required String userName,
    required String text,
  }) =>
      _dataSource.addComment(
        taskId: taskId,
        uid: uid,
        userName: userName,
        text: text,
      );

  @override
  Future<void> deleteComment({
    required String taskId,
    required String commentId,
  }) =>
      _dataSource.deleteComment(taskId: taskId, commentId: commentId);
}
