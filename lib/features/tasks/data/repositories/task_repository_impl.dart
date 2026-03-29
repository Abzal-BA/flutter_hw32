import '../../domain/entities/task.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements ITaskRepository {
  const TaskRepositoryImpl(this._dataSource);

  final TaskRemoteDataSource _dataSource;

  @override
  Stream<List<Task>> watchTasks({
    required String uid,
    required String statusFilter,
    required String categoryFilter,
    required String searchTag,
    required int limit,
  }) =>
      _dataSource.watchTasks(
        uid: uid,
        statusFilter: statusFilter,
        categoryFilter: categoryFilter,
        searchTag: searchTag,
        limit: limit,
      );

  @override
  Stream<Task?> watchTask(String taskId) => _dataSource.watchTask(taskId);

  @override
  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) =>
      _dataSource.addTask(
        uid: uid,
        title: title,
        description: description,
        status: status,
        category: category,
        tags: tags,
      );

  @override
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) =>
      _dataSource.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        status: status,
        category: category,
        tags: tags,
      );

  @override
  Future<void> deleteTask(String taskId) => _dataSource.deleteTask(taskId);
}
