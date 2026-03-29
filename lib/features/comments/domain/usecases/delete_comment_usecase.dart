import '../repositories/i_comment_repository.dart';

class DeleteCommentUseCase {
  const DeleteCommentUseCase(this._repository);

  final ICommentRepository _repository;

  Future<void> call({
    required String taskId,
    required String commentId,
  }) =>
      _repository.deleteComment(taskId: taskId, commentId: commentId);
}
