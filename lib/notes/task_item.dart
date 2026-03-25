import 'package:cloud_firestore/cloud_firestore.dart';

class TaskItem {
  const TaskItem({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.tags,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String uid;
  final String title;
  final String description;
  final String status;
  final String category;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdTimestamp = data['createdAt'];
    final updatedTimestamp = data['updatedAt'];

    return TaskItem(
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
