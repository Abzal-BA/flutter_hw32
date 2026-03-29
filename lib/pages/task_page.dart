import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_cubit.dart';
import '../di/service_locator.dart';
import '../notifications/notification_settings_screen.dart';
import '../notifications/task_details_screen.dart';
import '../notes/notes_cubit.dart';
import '../notes/notes_state.dart';
import '../notes/task_item.dart';
import 'user_settings_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _searchTagController = TextEditingController();
  late final NotesCubit _notesCubit;

  Future<void> _signOut() async {
    Navigator.of(context).pop();
    await context.read<AuthCubit>().signOut();
  }

  Future<void> _openNotificationSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
    );
  }

  Future<void> _openUserSettings() async {
    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserSettingsPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _notesCubit = getIt<NotesCubit>();
    _notesCubit.startListening();
  }

  @override
  void dispose() {
    _searchTagController.dispose();
    _notesCubit.close();
    super.dispose();
  }

  Future<void> _openCreateTaskDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _TaskEditorDialog(notesCubit: _notesCubit),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully.')),
      );
    }
  }

  Future<void> _openEditTaskDialog(TaskItem task) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _TaskEditorDialog(task: task, notesCubit: _notesCubit),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully.')),
      );
    }
  }

  Future<void> _confirmDeleteTask(TaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('This will permanently delete "${task.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notesCubit.deleteTask(task.id);
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Date pending...';
    final twoDigitsMonth = value.month.toString().padLeft(2, '0');
    final twoDigitsDay = value.day.toString().padLeft(2, '0');
    final twoDigitsHour = value.hour.toString().padLeft(2, '0');
    final twoDigitsMinute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$twoDigitsMonth-$twoDigitsDay $twoDigitsHour:$twoDigitsMinute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.menu),
                title: Text('Menu'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('User settings'),
                onTap: _openUserSettings,
              ),
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('Notification settings'),
                onTap: _openNotificationSettings,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: _signOut,
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Task Page'),
        actions: [
          IconButton(
            onPressed: _openNotificationSettings,
            tooltip: 'Notification settings',
            icon: const Icon(Icons.notifications_active),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchTagController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Search by tag (array-contains)',
                hintText: 'example: flutter',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () =>
                      _notesCubit.setSearchTag(_searchTagController.text),
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: _notesCubit.setSearchTag,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<NotesState>(
                    stream: _notesCubit.stream,
                    initialData: _notesCubit.state,
                    builder: (context, notesSnapshot) {
                      final notesState =
                          notesSnapshot.data ?? const NotesState();
                      return DropdownButtonFormField<String>(
                        initialValue: notesState.statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status filter',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All statuses'),
                          ),
                          DropdownMenuItem(value: 'todo', child: Text('To do')),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('In progress'),
                          ),
                          DropdownMenuItem(value: 'done', child: Text('Done')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _notesCubit.setStatusFilter(value);
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StreamBuilder<NotesState>(
                    stream: _notesCubit.stream,
                    initialData: _notesCubit.state,
                    builder: (context, notesSnapshot) {
                      final notesState =
                          notesSnapshot.data ?? const NotesState();
                      return DropdownButtonFormField<String>(
                        initialValue: notesState.categoryFilter,
                        decoration: const InputDecoration(
                          labelText: 'Category filter',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All categories'),
                          ),
                          DropdownMenuItem(
                            value: 'general',
                            child: Text('General'),
                          ),
                          DropdownMenuItem(
                            value: 'study',
                            child: Text('Study'),
                          ),
                          DropdownMenuItem(value: 'work', child: Text('Work')),
                          DropdownMenuItem(
                            value: 'personal',
                            child: Text('Personal'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _notesCubit.setCategoryFilter(value);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _searchTagController.clear();
                  _notesCubit.clearFilters();
                },
                child: const Text('Clear filters'),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: StreamBuilder<NotesState>(
                stream: _notesCubit.stream,
                initialData: _notesCubit.state,
                builder: (context, notesSnapshot) {
                  final notesState = notesSnapshot.data ?? const NotesState();

                  if (notesState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (notesState.errorMessage != null &&
                      notesState.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            notesState.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: _notesCubit.startListening,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (notesState.items.isEmpty) {
                    return const Center(
                      child: Text('No tasks yet. Add your first task.'),
                    );
                  }

                  return ListView.builder(
                    itemCount:
                        notesState.items.length + (notesState.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notesState.items.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: notesState.isLoadingMore
                                ? const CircularProgressIndicator()
                                : OutlinedButton(
                                    onPressed: _notesCubit.loadMore,
                                    child: const Text('Load 10 more'),
                                  ),
                          ),
                        );
                      }

                      final task = notesState.items[index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TaskDetailsScreen(taskId: task.id),
                              ),
                            );
                          },
                          title: Text(task.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(task.description),
                                ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  Chip(label: Text('Status: ${task.status}')),
                                  Chip(
                                    label: Text('Category: ${task.category}'),
                                  ),
                                  ...task.tags.map(
                                    (tag) => Chip(label: Text('#$tag')),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Created: ${_formatDate(task.createdAt)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _openEditTaskDialog(task),
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                onPressed: () => _confirmDeleteTask(task),
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
    );
  }
}

class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog({required this.notesCubit, this.task});

  final TaskItem? task;
  final NotesCubit notesCubit;

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  static const List<String> _statusOptions = <String>[
    'todo',
    'in_progress',
    'done',
  ];
  static const List<String> _categoryOptions = <String>[
    'general',
    'study',
    'work',
    'personal',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;

  late String _status;
  late String _category;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _tagsController = TextEditingController(text: task?.tags.join(', ') ?? '');
    _status = task?.status ?? 'todo';
    _category = task?.category ?? 'general';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _submitting = true;
    });

    final cubit = widget.notesCubit;
    final currentTask = widget.task;

    if (currentTask == null) {
      await cubit.addTask(
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        category: _category,
        tagsRaw: _tagsController.text,
      );
    } else {
      await cubit.updateTask(
        taskId: currentTask.id,
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        category: _category,
        tagsRaw: _tagsController.text,
      );
    }

    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add task' : 'Edit task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categoryOptions
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'flutter, homework',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.task == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
