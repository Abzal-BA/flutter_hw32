import 'package:cloud_firestore/cloud_firestore.dart';

import 'task_item.dart';

class NotesRepository {
  NotesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<TaskItem>> watchTasks({
    required String uid,
    required String statusFilter,
    required String categoryFilter,
    required String searchTag,
    required int limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('tasks')
        .where('uid', isEqualTo: uid);

    if (statusFilter != 'all') {
      query = query.where('status', isEqualTo: statusFilter);
    }
    if (categoryFilter != 'all') {
      query = query.where('category', isEqualTo: categoryFilter);
    }
    if (searchTag.isNotEmpty) {
      query = query.where('tags', arrayContains: searchTag);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map(TaskItem.fromDoc).toList();
    });
  }

  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) {
    return _firestore.collection('tasks').add(<String, dynamic>{
      'uid': uid,
      'title': title,
      'description': description,
      'status': status,
      'category': category,
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String status,
    required String category,
    required List<String> tags,
  }) {
    return _firestore.collection('tasks').doc(taskId).update(<String, dynamic>{
      'title': title,
      'description': description,
      'status': status,
      'category': category,
      'tags': tags,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String taskId) {
    return _firestore.collection('tasks').doc(taskId).delete();
  }
}
