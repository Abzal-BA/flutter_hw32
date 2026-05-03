import 'task.dart';

abstract class ITaskRepository {
  Future<List<Task>> fetchTasks({required String userId});

  Future<Task> addTask({required String userId, required String title});

  Future<Task> updateTaskStatus({
    required String userId,
    required String taskId,
    required String status,
  });
}
