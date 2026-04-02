import 'package:flutter_hw32/features/tasks/domain/entities/task.dart';
import 'package:flutter_hw32/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:flutter_hw32/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/task_fixtures.dart';

class MockTaskRepository implements ITaskRepository {
  String? capturedUid;
  String? capturedTitle;
  String? capturedDescription;
  String? capturedStatus;
  String? capturedCategory;
  List<String>? capturedTags;
  Exception? addTaskError;
  bool addTaskCalled = false;

  @override
  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) async {
    addTaskCalled = true;
    capturedUid = uid;
    capturedTitle = title;
    capturedDescription = description;
    capturedStatus = status;
    capturedCategory = category;
    capturedTags = tags;

    if (addTaskError != null) {
      throw addTaskError!;
    }
  }

  @override
  Future<void> deleteTask(String taskId) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Task?> watchTask(String taskId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Task>> watchTasks({
    required String uid,
    required String statusFilter,
    required String categoryFilter,
    required String searchTag,
    required int limit,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('AddTaskUseCase', () {
    late MockTaskRepository repository;
    late AddTaskUseCase useCase;

    setUp(() {
      repository = MockTaskRepository();
      useCase = AddTaskUseCase(repository);
    });

    test('passes params to repository', () async {
      await useCase(TaskFixtures.addTaskParams);

      expect(repository.addTaskCalled, isTrue);
      expect(repository.capturedUid, TaskFixtures.addTaskParams.uid);
      expect(repository.capturedTitle, TaskFixtures.addTaskParams.title);
      expect(
        repository.capturedDescription,
        TaskFixtures.addTaskParams.description,
      );
      expect(repository.capturedStatus, TaskFixtures.addTaskParams.status);
      expect(repository.capturedCategory, TaskFixtures.addTaskParams.category);
      expect(repository.capturedTags, TaskFixtures.addTaskParams.tags);
    });

    test('rethrows repository error with expected message', () async {
      repository.addTaskError = Exception('Failed to add task');

      await expectLater(
        () => useCase(TaskFixtures.addTaskParams),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Failed to add task'),
          ),
        ),
      );
    });
  });
}
