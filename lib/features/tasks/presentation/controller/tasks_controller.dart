import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error_handler.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/watch_tasks_usecase.dart';
import '../state/tasks_state.dart';

class TasksController extends ChangeNotifier {
  TasksController({
    required WatchTasksUseCase watchTasksUseCase,
    required AddTaskUseCase addTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required IAuthRepository authRepository,
    required AppErrorHandler errorHandler,
  })  : _watchTasksUseCase = watchTasksUseCase,
        _addTaskUseCase = addTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _authRepository = authRepository,
        _errorHandler = errorHandler;

  final WatchTasksUseCase _watchTasksUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final IAuthRepository _authRepository;
  final AppErrorHandler _errorHandler;

  TasksState _state = const TasksState();
  TasksState get state => _state;

  StreamSubscription<List<Task>>? _tasksSub;

  Future<void> loadTasks() async {
    await _subscribe(resetLoading: true);
  }

  Future<void> _subscribe({required bool resetLoading}) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'You must be logged in to access your tasks.',
      );
      notifyListeners();
      return;
    }

    if (resetLoading) {
      _state = _state.copyWith(isLoading: true, clearError: true);
      notifyListeners();
    }

    await _tasksSub?.cancel();

    _tasksSub = _watchTasksUseCase
        .call(WatchTasksParams(
          uid: uid,
          statusFilter: _state.statusFilter,
          categoryFilter: _state.categoryFilter,
          searchTag: _state.searchTag,
          limit: _state.limit,
        ))
        .listen(
          (items) {
            _state = _state.copyWith(
              items: List.unmodifiable(items),
              isLoading: false,
              isLoadingMore: false,
              hasMore: items.length >= _state.limit,
              clearError: true,
            );
            notifyListeners();
          },
          onError: (Object error) {
            _state = _state.copyWith(
              isLoading: false,
              isLoadingMore: false,
              errorMessage:
                  'Failed to load tasks: ${_errorHandler.toMessage(error)}',
            );
            notifyListeners();
          },
        );
  }

  Future<void> loadMore() async {
    if (_state.isLoadingMore || !_state.hasMore) return;
    _state = _state.copyWith(
      isLoadingMore: true,
      limit: _state.limit + 10,
      clearError: true,
    );
    notifyListeners();
    await _subscribe(resetLoading: false);
  }

  Future<void> setSearchTag(String value) async {
    _state = _state.copyWith(
      searchTag: value.trim().toLowerCase(),
      limit: 10,
      isLoadingMore: false,
    );
    notifyListeners();
    await _subscribe(resetLoading: true);
  }

  Future<void> setStatusFilter(String value) async {
    _state = _state.copyWith(
      statusFilter: value,
      limit: 10,
      isLoadingMore: false,
    );
    notifyListeners();
    await _subscribe(resetLoading: true);
  }

  Future<void> setCategoryFilter(String value) async {
    _state = _state.copyWith(
      categoryFilter: value,
      limit: 10,
      isLoadingMore: false,
    );
    notifyListeners();
    await _subscribe(resetLoading: true);
  }

  Future<void> clearFilters() async {
    _state = _state.copyWith(
      searchTag: '',
      statusFilter: 'all',
      categoryFilter: 'all',
      limit: 10,
      isLoadingMore: false,
    );
    notifyListeners();
    await _subscribe(resetLoading: true);
  }

  Future<bool> addTask({
    required String title,
    required String description,
    required String status,
    required String category,
    required String tagsRaw,
  }) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) {
      _state = _state.copyWith(errorMessage: 'Login required.');
      notifyListeners();
      return false;
    }

    final safeTitle = title.trim();
    if (safeTitle.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Title cannot be empty.');
      notifyListeners();
      return false;
    }

    try {
      await _addTaskUseCase.call(AddTaskParams(
        uid: uid,
        title: safeTitle,
        description: description.trim(),
        status: status,
        category: category,
        tags: _normalizeTags(tagsRaw),
      ));
      _state = _state.copyWith(clearError: true);
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(
        errorMessage:
            'Failed to add task: ${_errorHandler.toMessage(error)}',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required String category,
    required String tagsRaw,
  }) async {
    final safeTitle = title.trim();
    if (safeTitle.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Title cannot be empty.');
      notifyListeners();
      return false;
    }

    try {
      await _updateTaskUseCase.call(UpdateTaskParams(
        taskId: taskId,
        title: safeTitle,
        description: description.trim(),
        status: status,
        category: category,
        tags: _normalizeTags(tagsRaw),
      ));
      _state = _state.copyWith(clearError: true);
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(
        errorMessage:
            'Failed to update task: ${_errorHandler.toMessage(error)}',
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _deleteTaskUseCase.call(taskId);
      _state = _state.copyWith(clearError: true);
    } catch (error) {
      _state = _state.copyWith(
        errorMessage:
            'Failed to delete task: ${_errorHandler.toMessage(error)}',
      );
    }
    notifyListeners();
  }

  List<String> _normalizeTags(String raw) {
    final pieces = raw
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    pieces.sort();
    return pieces;
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }
}
