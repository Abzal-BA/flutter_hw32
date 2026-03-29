import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../notes/comments_screen.dart';
import '../notes/task_item.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({required this.taskId, super.key});

  final String taskId;

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    final twoDigitsMonth = value.month.toString().padLeft(2, '0');
    final twoDigitsDay = value.day.toString().padLeft(2, '0');
    final twoDigitsHour = value.hour.toString().padLeft(2, '0');
    final twoDigitsMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$twoDigitsMonth-$twoDigitsDay $twoDigitsHour:$twoDigitsMinute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task $taskId')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('tasks').doc(taskId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load task: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final doc = snapshot.data!;
          if (!doc.exists) {
            return const Center(child: Text('Task not found.'));
          }

          final task = TaskItem.fromDoc(doc);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(task.description.isEmpty ? '-' : task.description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('Status: ${task.status}')),
                  Chip(label: Text('Category: ${task.category}')),
                  ...task.tags.map((tag) => Chip(label: Text('#$tag'))),
                ],
              ),
              const SizedBox(height: 12),
              Text('Created: ${_formatDate(task.createdAt)}'),
              const SizedBox(height: 6),
              Text('Updated: ${_formatDate(task.updatedAt)}'),
              const SizedBox(height: 24),
              Divider(),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: CommentsScreen(taskId: taskId),
              ),
            ],
          );
        },
      ),
    );
  }
}