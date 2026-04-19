import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/item.dart';
import '../controller/items_controller.dart';

class TaskEditPage extends StatefulWidget {
  const TaskEditPage({required this.item, super.key});

  final Item item;

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  static const List<String> _statuses = <String>['todo', 'in_progress', 'done'];

  late String _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.item.status;
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    await context.read<ItemsController>().updateItemStatus(
      itemId: widget.item.id,
      status: _selectedStatus,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

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
            widget.item.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Created: ${widget.item.createdAt.toLocal().toIso8601String()}'),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            key: const ValueKey<String>('taskStatusField'),
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
          FilledButton(
            key: const ValueKey<String>('saveTaskStatusButton'),
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save status'),
          ),
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
