import 'package:flutter/material.dart';

import '../../../../di/service_locator.dart';
import '../../../comments/presentation/pages/comments_screen.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/watch_task_usecase.dart';

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
    return StreamBuilder<Task?>(
      stream: getIt<WatchTaskUseCase>().call(taskId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Details')),
            body: Center(
                child: Text('Failed to load task: ${snapshot.error}')),
          );
        }

        final task = snapshot.data;
        final appBarTitle = task?.title ?? 'Task Details';

        if (!snapshot.hasData || task == null) {
          return Scaffold(
            appBar: AppBar(title: Text(appBarTitle)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(appBarTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(task.title,
                  style: Theme.of(context).textTheme.headlineSmall),
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
              const Divider(),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: CommentsScreen(taskId: taskId),
              ),
            ],
          ),
        );
      },
    );
  }
}
