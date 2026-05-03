import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error_handler.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/i_task_repository.dart';
import '../../domain/task.dart';
import '../state/tasks_state.dart';

class TasksController extends ChangeNotifier {
  TasksController({
    required ITaskRepository taskRepository,
    required IAuthRepository authRepository,
    required AppErrorHandler errorHandler,
  }) : _taskRepository = taskRepository,
       _authRepository = authRepository,
       _errorHandler = errorHandler;

  final ITaskRepository _taskRepository;
  final IAuthRepository _authRepository;
  final AppErrorHandler _errorHandler;

  TasksState _state = const TasksState();

  TasksState get state => _state;

  void _emit(TasksState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Sign in first to load tasks.'));
      return;
    }

    _emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final tasks = await _taskRepository.fetchTasks(userId: userId);
      _emit(state.copyWith(items: tasks, isLoading: false, errorMessage: null));
    } catch (error) {
      _emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _errorHandler.toMessage(error),
        ),
      );
    }
  }

  Future<void> addTask(String title) async {
    final userId = _authRepository.currentUser?.uid;
    final safeTitle = title.trim();
    if (userId == null || userId.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Sign in first to add tasks.'));
      return;
    }
    if (safeTitle.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Enter a task title.'));
      return;
    }

    _emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      final created = await _taskRepository.addTask(
        userId: userId,
        title: safeTitle,
      );
      _emit(
        state.copyWith(
          items: <Task>[created, ...state.items],
          isSaving: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      _emit(
        state.copyWith(
          isSaving: false,
          errorMessage: _errorHandler.toMessage(error),
        ),
      );
    }
  }

  Future<void> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Sign in first to update tasks.'));
      return;
    }

    _emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      final updated = await _taskRepository.updateTaskStatus(
        userId: userId,
        taskId: taskId,
        status: status,
      );
      final next = state.items
          .map((task) => task.id == taskId ? updated : task)
          .toList(growable: false);
      _emit(state.copyWith(items: next, isSaving: false, errorMessage: null));
    } catch (error) {
      _emit(
        state.copyWith(
          isSaving: false,
          errorMessage: _errorHandler.toMessage(error),
        ),
      );
    }
  }
}
