import '../repositories/i_task_repository.dart';

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final ITaskRepository _repository;

  Future<void> call(String taskId) => _repository.deleteTask(taskId);
}
