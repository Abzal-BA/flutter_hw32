import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hw32/features/tasks/domain/usecases/add_task_usecase.dart';

final class TaskFixtures {
  const TaskFixtures._();

  static final DateTime createdAt = DateTime.utc(2024, 1, 10, 8, 30);
  static final DateTime updatedAt = DateTime.utc(2024, 1, 11, 9, 45);

  static Map<String, dynamic> validDocData({
    Object? createdAt,
    Object? updatedAt,
    List<dynamic>? tags,
  }) {
    return <String, dynamic>{
      'uid': 'user-1',
      'title': 'Write tests',
      'description': 'Cover mapper and use case',
      'status': 'in_progress',
      'category': 'study',
      'tags': tags ?? <dynamic>['flutter', 'testing'],
      'createdAt': createdAt ?? Timestamp.fromDate(TaskFixtures.createdAt),
      'updatedAt': updatedAt ?? Timestamp.fromDate(TaskFixtures.updatedAt),
    };
  }

  static const AddTaskParams addTaskParams = AddTaskParams(
    uid: 'user-42',
    title: 'Finish homework',
    description: 'Add unit tests and coverage',
    status: 'todo',
    category: 'education',
    tags: <String>['dart', 'flutter'],
  );
}
