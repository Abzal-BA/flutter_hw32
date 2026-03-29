import '../entities/comment.dart';
import '../repositories/i_comment_repository.dart';

class WatchCommentsUseCase {
  const WatchCommentsUseCase(this._repository);

  final ICommentRepository _repository;

  Stream<List<Comment>> call(String taskId) =>
      _repository.watchComments(taskId);
}
