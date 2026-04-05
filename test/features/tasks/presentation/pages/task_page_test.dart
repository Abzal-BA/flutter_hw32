import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hw32/core/error/app_error_handler.dart';
import 'package:flutter_hw32/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_hw32/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_hw32/features/tasks/domain/entities/task.dart';
import 'package:flutter_hw32/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:flutter_hw32/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:flutter_hw32/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_hw32/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:flutter_hw32/features/tasks/domain/usecases/watch_tasks_usecase.dart';
import 'package:flutter_hw32/features/tasks/presentation/controller/tasks_controller.dart';
import 'package:flutter_hw32/features/tasks/presentation/pages/task_page.dart';

void main() {
  group('TaskPage', () {
    late _FakeTaskRepository repository;
    late TasksController controller;

    setUp(() {
      repository = _FakeTaskRepository();
      controller = TasksController(
        watchTasksUseCase: WatchTasksUseCase(repository),
        addTaskUseCase: AddTaskUseCase(repository),
        updateTaskUseCase: UpdateTaskUseCase(repository),
        deleteTaskUseCase: DeleteTaskUseCase(repository),
        authRepository: const _FakeAuthRepository(),
        errorHandler: AppErrorHandler(),
      );
    });

    tearDown(() async {
      controller.dispose();
      await repository.dispose();
    });

    testWidgets('shows loading, then empty state, then list items', (
      tester,
    ) async {
      await _pumpTaskPage(tester, controller);

      expect(find.byKey(TaskPageKeys.loadingIndicator), findsOneWidget);

      repository.emit(const <Task>[]);
      await tester.pump();

      expect(find.byKey(TaskPageKeys.emptyState), findsOneWidget);
      expect(find.text('No tasks yet. Add your first task.'), findsOneWidget);

      repository.emit(<Task>[_task(id: 'task-1', title: 'Read a book')]);
      await tester.pump();

      expect(find.byKey(TaskPageKeys.listView), findsOneWidget);
      expect(find.text('Read a book'), findsOneWidget);
      expect(find.byKey(TaskPageKeys.taskTile('task-1')), findsOneWidget);
    });

    testWidgets('adds a task from the dialog and shows it in the list', (
      tester,
    ) async {
      await _pumpTaskPage(tester, controller);
      repository.emit(const <Task>[]);
      await tester.pump();

      await tester.tap(find.byKey(TaskPageKeys.addFab));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(TaskPageKeys.titleField),
        'Buy groceries',
      );
      await tester.tap(find.byKey(TaskPageKeys.submitButton));
      await tester.pumpAndSettle();

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('Task created successfully.'), findsOneWidget);
    });

    testWidgets('shows an error message when loading fails', (tester) async {
      await _pumpTaskPage(tester, controller);

      repository.emitError(Exception('Network down'));
      await tester.pump();

      expect(find.byKey(TaskPageKeys.errorText), findsOneWidget);
      expect(find.text('Failed to load tasks: Network down'), findsOneWidget);
      expect(find.byKey(TaskPageKeys.retryButton), findsOneWidget);
    });

    testWidgets('navigates to the details screen when a task is tapped', (
      tester,
    ) async {
      await _pumpTaskPage(
        tester,
        controller,
        taskDetailsPageBuilder: (taskId) => Scaffold(
          body: Center(child: Text('Details for $taskId')),
        ),
      );
      repository.emit(<Task>[_task(id: 'task-7', title: 'Open details')]);
      await tester.pump();

      await tester.tap(find.byKey(TaskPageKeys.taskTile('task-7')));
      await tester.pumpAndSettle();

      expect(find.text('Details for task-7'), findsOneWidget);
    });
  });
}

Future<void> _pumpTaskPage(
  WidgetTester tester,
  TasksController controller, {
  Widget Function(String taskId)? taskDetailsPageBuilder,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: TaskPage(
        tasksController: controller,
        notificationsEnabledListenable: ValueNotifier<bool>(true),
        taskDetailsPageBuilder: taskDetailsPageBuilder,
      ),
    ),
  );
}

Task _task({
  required String id,
  required String title,
}) {
  return Task(
    id: id,
    uid: 'user-1',
    title: title,
    description: '',
    status: 'todo',
    category: 'general',
    tags: const <String>[],
    createdAt: DateTime(2026, 4, 5, 12, 0),
    updatedAt: DateTime(2026, 4, 5, 12, 0),
  );
}

class _FakeAuthRepository implements IAuthRepository {
  const _FakeAuthRepository();

  @override
  Stream<AuthUser?> get authStateChanges =>
      Stream<AuthUser?>.value(currentUser);

  @override
  AuthUser? get currentUser => const AuthUser(uid: 'user-1');

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordReset(String email) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateDisplayName(String displayName) {
    throw UnimplementedError();
  }
}

class _FakeTaskRepository implements ITaskRepository {
  final StreamController<List<Task>> _controller =
      StreamController<List<Task>>.broadcast();
  List<Task> _items = <Task>[];
  int _nextId = 1;

  void emit(List<Task> items) {
    _items = List<Task>.unmodifiable(items);
    _controller.add(_items);
  }

  void emitError(Object error) {
    _controller.addError(error);
  }

  Future<void> dispose() => _controller.close();

  @override
  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) async {
    final task = Task(
      id: 'task-${_nextId++}',
      uid: uid,
      title: title,
      description: description,
      status: status,
      category: category,
      tags: List<String>.unmodifiable(tags),
      createdAt: DateTime(2026, 4, 5, 12, 0),
      updatedAt: DateTime(2026, 4, 5, 12, 0),
    );
    _items = List<Task>.unmodifiable(<Task>[..._items, task]);
    _controller.add(_items);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _items = List<Task>.unmodifiable(
      _items.where((task) => task.id != taskId),
    );
    _controller.add(_items);
  }

  @override
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) async {
    _items = List<Task>.unmodifiable(
      _items.map((task) {
        if (task.id != taskId) {
          return task;
        }
        return Task(
          id: task.id,
          uid: task.uid,
          title: title,
          description: description,
          status: status,
          category: category,
          tags: List<String>.unmodifiable(tags),
          createdAt: task.createdAt,
          updatedAt: DateTime(2026, 4, 5, 12, 0),
        );
      }),
    );
    _controller.add(_items);
  }

  @override
  Stream<Task?> watchTask(String taskId) {
    return _controller.stream.map(
      (items) => items.cast<Task?>().firstWhere(
            (task) => task?.id == taskId,
            orElse: () => null,
          ),
    );
  }

  @override
  Stream<List<Task>> watchTasks({
    required String uid,
    required String statusFilter,
    required String categoryFilter,
    required String searchTag,
    required int limit,
  }) {
    return _controller.stream.map(
      (items) => items
          .where((task) => task.uid == uid)
          .where(
            (task) => statusFilter == 'all' || task.status == statusFilter,
          )
          .where(
            (task) =>
                categoryFilter == 'all' || task.category == categoryFilter,
          )
          .where(
            (task) =>
                searchTag.isEmpty || task.tags.contains(searchTag),
          )
          .take(limit)
          .toList(growable: false),
    );
  }
}
