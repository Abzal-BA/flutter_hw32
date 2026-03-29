import '../repositories/i_comment_repository.dart';

class AddCommentParams {
  const AddCommentParams({
    required this.taskId,
    required this.uid,
    required this.userName,
    required this.text,
  });

  final String taskId;
  final String uid;
  final String userName;
  final String text;
}

class AddCommentUseCase {
  const AddCommentUseCase(this._repository);

  final ICommentRepository _repository;

  Future<void> call(AddCommentParams params) => _repository.addComment(
        taskId: params.taskId,
        uid: params.uid,
        userName: params.userName,
        text: params.text,
      );
}
