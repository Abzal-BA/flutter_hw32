import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notes_state.dart';
import 'task_item.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit({required FirebaseFirestore firestore, required FirebaseAuth auth})
    : _firestore = firestore,
      _auth = auth,
      super(const NotesState());

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tasksSub;

  // Task: Real-time list via snapshots() with proper loading/error/empty handling.
  Future<void> startListening() async {
    await _subscribe(resetLoading: true);
  }

  Future<void> _subscribe({required bool resetLoading}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'You must be logged in to access your tasks.',
        ),
      );
      return;
    }

    if (resetLoading) {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }

    await _tasksSub?.cancel();

    Query<Map<String, dynamic>> query = _firestore
        .collection('tasks')
        .where('uid', isEqualTo: uid);

    // Task: Filters by status and category.
    if (state.statusFilter != 'all') {
      query = query.where('status', isEqualTo: state.statusFilter);
    }
    if (state.categoryFilter != 'all') {
      query = query.where('category', isEqualTo: state.categoryFilter);
    }

    // Task: Search by field using array-contains on tags.
    if (state.searchTag.isNotEmpty) {
      query = query.where('tags', arrayContains: state.searchTag.toLowerCase());
    }

    // Task: Pagination by 10 items + load more via increasing limit.
    query = query.orderBy('createdAt', descending: true).limit(state.limit);

    _tasksSub = query.snapshots().listen(
      (snapshot) {
        final items = snapshot.docs.map(TaskItem.fromDoc).toList();
        emit(
          state.copyWith(
            items: items,
            isLoading: false,
            isLoadingMore: false,
            hasMore: items.length >= state.limit,
            errorMessage: null,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: 'Failed to load tasks: $error',
          ),
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(
      state.copyWith(
        isLoadingMore: true,
        limit: state.limit + 10,
        errorMessage: null,
      ),
    );
    await _subscribe(resetLoading: false);
  }

  Future<void> setSearchTag(String value) async {
    emit(
      state.copyWith(
        searchTag: value.trim().toLowerCase(),
        limit: 10,
        isLoadingMore: false,
      ),
    );
    await _subscribe(resetLoading: true);
  }

  Future<void> setStatusFilter(String value) async {
    emit(state.copyWith(statusFilter: value, limit: 10, isLoadingMore: false));
    await _subscribe(resetLoading: true);
  }

  Future<void> setCategoryFilter(String value) async {
    emit(
      state.copyWith(categoryFilter: value, limit: 10, isLoadingMore: false),
    );
    await _subscribe(resetLoading: true);
  }

  Future<void> clearFilters() async {
    emit(
      state.copyWith(
        searchTag: '',
        statusFilter: 'all',
        categoryFilter: 'all',
        limit: 10,
        isLoadingMore: false,
      ),
    );
    await _subscribe(resetLoading: true);
  }

  // Task: Firestore CRUD - add task.
  Future<void> addTask({
    required String title,
    required String description,
    required String status,
    required String category,
    required String tagsRaw,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(errorMessage: 'Login required.'));
      return;
    }

    final safeTitle = title.trim();
    if (safeTitle.isEmpty) {
      emit(state.copyWith(errorMessage: 'Title cannot be empty.'));
      return;
    }

    final tags = _normalizeTags(tagsRaw);

    try {
      await _firestore.collection('tasks').add(<String, dynamic>{
        'uid': uid,
        'title': safeTitle,
        'description': description.trim(),
        'status': status,
        'category': category,
        'tags': tags,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      emit(state.copyWith(errorMessage: 'Failed to add task: $error'));
    }
  }

  // Task: Firestore CRUD - update task.
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required String category,
    required String tagsRaw,
  }) async {
    final safeTitle = title.trim();
    if (safeTitle.isEmpty) {
      emit(state.copyWith(errorMessage: 'Title cannot be empty.'));
      return;
    }

    final tags = _normalizeTags(tagsRaw);

    try {
      await _firestore.collection('tasks').doc(taskId).update(<String, dynamic>{
        'title': safeTitle,
        'description': description.trim(),
        'status': status,
        'category': category,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      emit(state.copyWith(errorMessage: 'Failed to update task: $error'));
    }
  }

  // Task: Firestore CRUD - delete task.
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (error) {
      emit(state.copyWith(errorMessage: 'Failed to delete task: $error'));
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

  @override
  Future<void> close() async {
    await _tasksSub?.cancel();
    return super.close();
  }
}
