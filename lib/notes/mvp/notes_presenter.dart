import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error_handler.dart';
import '../notes_repository.dart';
import '../task_item.dart';
import 'notes_mvp_state.dart';
import 'notes_mvp_view.dart';

class NotesPresenter {
  // Day35 Task 2: Presenter contains application logic for MVP flow.
  // Day35 Task 3 and 5: load/add logic + unified error mapping are handled here.
  NotesPresenter({
    required FirebaseAuth auth,
    required NotesRepository repository,
    required AppErrorHandler errorHandler,
  })  : _auth = auth,
        _repository = repository,
        _errorHandler = errorHandler;

  final FirebaseAuth _auth;
  final NotesRepository _repository;
  final AppErrorHandler _errorHandler;

  NotesMvpView? _view;
  StreamSubscription<List<TaskItem>>? _tasksSub;
  NotesMvpState _state = const NotesMvpState();

  NotesMvpState get state => _state;

  void attach(NotesMvpView view) {
    _view = view;
    _view?.render(_state);
  }

  void detach() {
    _view = null;
  }

  void _emit(NotesMvpState value) {
    _state = value;
    _view?.render(_state);
  }

  Future<void> startListening() async {
    await loadTasks();
  }

  Future<void> loadTasks() async {
    await _subscribe(resetLoading: true);
  }

  Future<void> _subscribe({required bool resetLoading}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'You must be logged in to access your tasks.',
        ),
      );
      return;
    }

    if (resetLoading) {
      _emit(_state.copyWith(isLoading: true, clearError: true));
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
            _emit(
              _state.copyWith(
                items: List.unmodifiable(items),
                isLoading: false,
                isLoadingMore: false,
                hasMore: items.length >= _state.limit,
                clearError: true,
              ),
            );
          },
          onError: (Object error) {
            _emit(
              _state.copyWith(
                isLoading: false,
                isLoadingMore: false,
                errorMessage: 'Failed to load tasks: ${_errorHandler.toMessage(error)}',
              ),
            );
          },
        );
  }

  Future<void> loadMore() async {
    if (_state.isLoadingMore || !_state.hasMore) return;

    _emit(
      _state.copyWith(
        isLoadingMore: true,
        limit: _state.limit + 10,
        clearError: true,
      ),
    );

    await _subscribe(resetLoading: false);
  }

  Future<void> setSearchTag(String value) async {
    _emit(
      _state.copyWith(
        searchTag: value.trim().toLowerCase(),
        limit: 10,
        isLoadingMore: false,
      ),
    );
    await _subscribe(resetLoading: true);
  }

  Future<void> setStatusFilter(String value) async {
    _emit(_state.copyWith(statusFilter: value, limit: 10, isLoadingMore: false));
    await _subscribe(resetLoading: true);
  }

  Future<void> setCategoryFilter(String value) async {
    _emit(
      _state.copyWith(
        categoryFilter: value,
        limit: 10,
        isLoadingMore: false,
      ),
    );
    await _subscribe(resetLoading: true);
  }

  Future<void> clearFilters() async {
    _emit(
      _state.copyWith(
        searchTag: '',
        statusFilter: 'all',
        categoryFilter: 'all',
        limit: 10,
        isLoadingMore: false,
      ),
    );
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
      _emit(_state.copyWith(errorMessage: 'Login required.'));
      return false;
    }

    final safeTitle = title.trim();
    if (safeTitle.isEmpty) {
      _emit(_state.copyWith(errorMessage: 'Title cannot be empty.'));
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
      _emit(_state.copyWith(clearError: true));
      return true;
    } catch (error) {
      _emit(
        _state.copyWith(
          errorMessage: 'Failed to add task: ${_errorHandler.toMessage(error)}',
        ),
      );
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
      _emit(_state.copyWith(errorMessage: 'Title cannot be empty.'));
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
      _emit(_state.copyWith(clearError: true));
      return true;
    } catch (error) {
      _emit(
        _state.copyWith(
          errorMessage: 'Failed to update task: ${_errorHandler.toMessage(error)}',
        ),
      );
      return false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      _emit(_state.copyWith(clearError: true));
    } catch (error) {
      _emit(
        _state.copyWith(
          errorMessage: 'Failed to delete task: ${_errorHandler.toMessage(error)}',
        ),
      );
    }
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

  Future<void> dispose() async {
    await _tasksSub?.cancel();
  }
}
