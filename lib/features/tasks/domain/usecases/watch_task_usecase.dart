import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

class WatchTaskUseCase {
  const WatchTaskUseCase(this._repository);

  final ITaskRepository _repository;

  Stream<Task?> call(String taskId) => _repository.watchTask(taskId);
}
