import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/error_handler.dart';
import 'notes_repository.dart';
import 'task_item.dart';
import 'notes_view_state.dart';

class NotesController extends ChangeNotifier {
  // Day35 Task 3: UI delegates load/add logic to controller methods.
  // Day35 Task 5: All errors are mapped through AppErrorHandler.
  NotesController({
    required FirebaseAuth auth,
    required NotesRepository repository,
    required AppErrorHandler errorHandler,
  })  : _auth = auth,
        _repository = repository,
        _errorHandler = errorHandler;

  final FirebaseAuth _auth;
  final NotesRepository _repository;
  final AppErrorHandler _errorHandler;

  NotesViewState _state = const NotesViewState();
  NotesViewState get state => _state;

  StreamSubscription<List<TaskItem>>? _tasksSub;

  Future<void> startListening() async {
    await loadTasks();
  }

  Future<void> loadTasks() async {
    await _subscribe(resetLoading: true);
  }

  Future<void> _subscribe({required bool resetLoading}) async {
    final uid = _auth.currentUser?.uid;
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

    _tasksSub = _repository
        .watchTasks(
          uid: uid,
          statusFilter: _state.statusFilter,
          categoryFilter: _state.categoryFilter,
          searchTag: _state.searchTag,
          limit: _state.limit,
        )
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
              errorMessage: 'Failed to load tasks: ${_errorHandler.toMessage(error)}',
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
    _state = _state.copyWith(statusFilter: value, limit: 10, isLoadingMore: false);
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
    final uid = _auth.currentUser?.uid;
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
      await _repository.addTask(
        uid: uid,
        title: safeTitle,
        description: description.trim(),
        status: status,
        category: category,
        tags: _normalizeTags(tagsRaw),
      );
      _state = _state.copyWith(clearError: true);
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(
        errorMessage: 'Failed to add task: ${_errorHandler.toMessage(error)}',
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
      await _repository.updateTask(
        taskId: taskId,
        title: safeTitle,
        description: description.trim(),
        status: status,
        category: category,
        tags: _normalizeTags(tagsRaw),
      );
      _state = _state.copyWith(clearError: true);
      notifyListeners();
      return true;
    } catch (error) {
      _state = _state.copyWith(
        errorMessage: 'Failed to update task: ${_errorHandler.toMessage(error)}',
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      _state = _state.copyWith(clearError: true);
    } catch (error) {
      _state = _state.copyWith(
        errorMessage: 'Failed to delete task: ${_errorHandler.toMessage(error)}',
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
