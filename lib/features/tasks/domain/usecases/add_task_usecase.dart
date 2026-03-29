import '../repositories/i_task_repository.dart';

class AddTaskParams {
  const AddTaskParams({
    required this.uid,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.tags,
  });

  final String uid;
  final String title;
  final String description;
  final String status;
  final String category;
  final List<String> tags;
}

class AddTaskUseCase {
  const AddTaskUseCase(this._repository);

  final ITaskRepository _repository;

  Future<void> call(AddTaskParams params) => _repository.addTask(
        uid: params.uid,
        title: params.title,
        description: params.description,
        status: params.status,
        category: params.category,
        tags: params.tags,
      );
}
