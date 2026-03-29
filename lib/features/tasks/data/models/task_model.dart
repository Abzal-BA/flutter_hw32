import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.uid,
    required super.title,
    required super.description,
    required super.status,
    required super.category,
    required super.tags,
    super.createdAt,
    super.updatedAt,
  });

  factory TaskModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdTimestamp = data['createdAt'];
    final updatedTimestamp = data['updatedAt'];

    return TaskModel(
      id: doc.id,
      uid: (data['uid'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      status: (data['status'] ?? 'todo').toString(),
      category: (data['category'] ?? 'general').toString(),
      tags: ((data['tags'] as List?) ?? const <dynamic>[])
          .map((tag) => tag.toString())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      createdAt: createdTimestamp is Timestamp
          ? createdTimestamp.toDate()
          : null,
      updatedAt: updatedTimestamp is Timestamp
          ? updatedTimestamp.toDate()
          : null,
    );
  }
}
