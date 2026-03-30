import 'package:flutter/material.dart';

import '../../../../di/service_locator.dart';
import '../../../../core/widgets/status_widget_factory.dart';
import '../../../comments/presentation/pages/comments_screen.dart';
import '../viewmodel/task_details_view_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({required this.taskId, super.key});

  final String taskId;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late final TaskDetailsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<TaskDetailsViewModel>(param1: widget.taskId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

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
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        if (_viewModel.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Details')),
            body: Center(
              // Day 37 status factory usage: error widget is created by factory.
              child: StatusWidgetFactory.create(
                StatusWidgetType.error,
                message: _viewModel.errorMessage!,
              ),
            ),
          );
        }

        final task = _viewModel.task;
        final appBarTitle = _viewModel.title;

        if (_viewModel.isLoading || task == null) {
          return Scaffold(
            appBar: AppBar(title: Text(appBarTitle)),
            body: Center(
              // Day 37 status factory usage: loading widget is created by factory.
              child: StatusWidgetFactory.create(
                StatusWidgetType.loading,
                message: 'Loading task details...',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(appBarTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
              // Day 37 status factory usage: success widget is created by factory.
              const SizedBox(height: 12),
              StatusWidgetFactory.create(
                StatusWidgetType.success,
                message: 'Task loaded successfully.',
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: CommentsScreen(taskId: widget.taskId),
              ),
            ],
          ),
        );
      },
    );
  }
}
