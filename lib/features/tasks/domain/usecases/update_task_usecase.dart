import '../repositories/i_task_repository.dart';

class UpdateTaskParams {
  const UpdateTaskParams({
    required this.taskId,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.tags,
  });

  final String taskId;
  final String title;
  final String description;
  final String status;
  final String category;
  final List<String> tags;
}

class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final ITaskRepository _repository;

  Future<void> call(UpdateTaskParams params) => _repository.updateTask(
        taskId: params.taskId,
        title: params.title,
        description: params.description,
        status: params.status,
        category: params.category,
        tags: params.tags,
      );
}
