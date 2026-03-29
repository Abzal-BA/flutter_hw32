import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

class WatchTasksParams {
  const WatchTasksParams({
    required this.uid,
    required this.statusFilter,
    required this.categoryFilter,
    required this.searchTag,
    required this.limit,
  });

  final String uid;
  final String statusFilter;
  final String categoryFilter;
  final String searchTag;
  final int limit;
}

class WatchTasksUseCase {
  const WatchTasksUseCase(this._repository);

  final ITaskRepository _repository;

  Stream<List<Task>> call(WatchTasksParams params) => _repository.watchTasks(
        uid: params.uid,
        statusFilter: params.statusFilter,
        categoryFilter: params.categoryFilter,
        searchTag: params.searchTag,
        limit: params.limit,
      );
}
