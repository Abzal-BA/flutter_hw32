import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/task.dart';
import '../controller/tasks_controller.dart';

class TaskEditPage extends StatefulWidget {
  const TaskEditPage({required this.task, super.key});

  final Task task;

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  static const List<String> _statuses = <String>['todo', 'in_progress', 'done'];

  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
  }

  Future<void> _save() async {
    await context.read<TasksController>().updateTaskStatus(
      taskId: widget.task.id,
      status: _selectedStatus,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.task.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Created: ${widget.task.createdAt.toLocal().toIso8601String()}'),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Task status',
              border: OutlineInputBorder(),
            ),
            items: _statuses
                .map(
                  (status) => DropdownMenuItem<String>(
                    value: status,
                    child: Text(_labelForStatus(status)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save status')),
        ],
      ),
    );
  }

  String _labelForStatus(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      case 'todo':
      default:
        return 'To Do';
    }
  }
}
