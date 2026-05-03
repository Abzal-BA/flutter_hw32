import '../domain/i_task_repository.dart';
import '../domain/task.dart';

class InMemoryTaskRepository implements ITaskRepository {
  final Map<String, List<Task>> _storage = <String, List<Task>>{};

  @override
  Future<Task> addTask({required String userId, required String title}) async {
    final current = _tasksFor(userId);
    final created = Task(
      id: 'task-${current.length + 1}',
      title: title,
      status: 'todo',
      createdAt: DateTime.now(),
    );
    _storage[userId] = <Task>[created, ...current];
    return created;
  }

  @override
  Future<List<Task>> fetchTasks({required String userId}) async {
    if (!_storage.containsKey(userId)) {
      _storage[userId] = <Task>[
        Task(
          id: 'task-1',
          title: 'Check release artifacts',
          status: 'todo',
          createdAt: DateTime(2026, 5, 3, 9),
        ),
        Task(
          id: 'task-2',
          title: 'Review profile settings',
          status: 'in_progress',
          createdAt: DateTime(2026, 5, 3, 10),
        ),
      ];
    }

    return List<Task>.unmodifiable(_tasksFor(userId));
  }

  @override
  Future<Task> updateTaskStatus({
    required String userId,
    required String taskId,
    required String status,
  }) async {
    final current = _tasksFor(userId);
    final index = current.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      throw Exception('Task not found.');
    }

    final updated = current[index].copyWith(status: status);
    final next = List<Task>.from(current);
    next[index] = updated;
    _storage[userId] = next;
    return updated;
  }

  List<Task> _tasksFor(String userId) =>
      List<Task>.from(_storage[userId] ?? const <Task>[]);
}
