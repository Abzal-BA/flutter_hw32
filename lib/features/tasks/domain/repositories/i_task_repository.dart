import '../entities/task.dart';

abstract class ITaskRepository {
  Stream<List<Task>> watchTasks({
    required String uid,
    required String statusFilter,
    required String categoryFilter,
    required String searchTag,
    required int limit,
  });

  Stream<Task?> watchTask(String taskId);

  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  });

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  });

  Future<void> deleteTask(String taskId);
}
