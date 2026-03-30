import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/parsing/api_response_parser.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  const TaskRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Task>> watchTasks({
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
    // Day 37 parser factory usage: task Firestore payloads are parsed via a selected parser.
    final parser = ApiResponseParserFactory.create<TaskModel>(
      ApiResponseType.task,
    );
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) =>
                parser.parse(ApiResponseContext(data: doc.data(), id: doc.id)),
          )
          .toList(),
    );
  }

  Stream<Task?> watchTask(String taskId) {
    // Day 37 parser factory usage: single task payload parsing goes through the same factory.
    final parser = ApiResponseParserFactory.create<TaskModel>(
      ApiResponseType.task,
    );
    return _firestore
        .collection('tasks')
        .doc(taskId)
        .snapshots()
        .map(
          (doc) => doc.exists
              ? parser.parse(ApiResponseContext(data: doc.data()!, id: doc.id))
              : null,
        );
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
