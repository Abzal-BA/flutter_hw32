import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../di/service_locator.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../notifications/notification_service.dart';
import '../../../notifications/presentation/pages/notification_settings_screen.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/add_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/watch_tasks_usecase.dart';
import '../../../auth/domain/repositories/i_auth_repository.dart';
import '../../../../core/error/app_error_handler.dart';
import '../controller/tasks_controller.dart';
import '../state/tasks_state.dart';
import 'task_details_screen.dart';
import '../../../auth/presentation/pages/user_settings_page.dart';

class TaskPageKeys {
  const TaskPageKeys._();

  static const loadingIndicator = ValueKey<String>('taskPage_loading');
  static const emptyState = ValueKey<String>('taskPage_empty');
  static const errorText = ValueKey<String>('taskPage_errorText');
  static const retryButton = ValueKey<String>('taskPage_retryButton');
  static const listView = ValueKey<String>('taskPage_listView');
  static const addFab = ValueKey<String>('taskPage_addFab');
  static const titleField = ValueKey<String>('taskPage_titleField');
  static const submitButton = ValueKey<String>('taskPage_submitButton');

  static Key taskTile(String taskId) => ValueKey<String>('taskTile_$taskId');
}

class TaskPage extends StatefulWidget {
  const TaskPage({
    super.key,
    this.tasksController,
    this.notificationsEnabledListenable,
    this.taskDetailsPageBuilder,
  });

  final TasksController? tasksController;
  final ValueListenable<bool>? notificationsEnabledListenable;
  final Widget Function(String taskId)? taskDetailsPageBuilder;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _searchTagController = TextEditingController();
  late final TasksController _tasksController;
  late final ValueListenable<bool> _notificationsEnabledListenable;
  late final bool _ownsTasksController;

  Future<void> _signOut() async {
    Navigator.of(context).pop();
    await context.read<AuthController>().signOut();
  }

  Future<void> _openNotificationSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const NotificationSettingsScreen()),
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
    _tasksController = widget.tasksController ??
        TasksController(
          watchTasksUseCase: getIt<WatchTasksUseCase>(),
          addTaskUseCase: getIt<AddTaskUseCase>(),
          updateTaskUseCase: getIt<UpdateTaskUseCase>(),
          deleteTaskUseCase: getIt<DeleteTaskUseCase>(),
          authRepository: getIt<IAuthRepository>(),
          errorHandler: getIt<AppErrorHandler>(),
        );
    _ownsTasksController = widget.tasksController == null;
    _notificationsEnabledListenable =
        widget.notificationsEnabledListenable ??
            getIt<NotificationService>().notificationsEnabled;
    _tasksController.loadTasks();
  }

  @override
  void dispose() {
    _searchTagController.dispose();
    if (_ownsTasksController) {
      _tasksController.dispose();
    }
    super.dispose();
  }

  Future<void> _openCreateTaskDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _TaskEditorDialog(tasksController: _tasksController),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully.')),
      );
    }
  }

  Future<void> _openEditTaskDialog(Task task) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => _TaskEditorDialog(
          task: task, tasksController: _tasksController),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully.')),
      );
    }
  }

  Future<void> _confirmDeleteTask(Task task) async {
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
      await _tasksController.deleteTask(task.id);
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
                onTap: () {
                  Navigator.of(context).pop();
                  _openNotificationSettings();
                },
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
          ValueListenableBuilder<bool>(
            valueListenable: _notificationsEnabledListenable,
            builder: (context, enabled, _) {
              return IconButton(
                onPressed: _openNotificationSettings,
                tooltip: enabled
                    ? 'Notifications are enabled'
                    : 'Notifications are muted',
                icon: Icon(
                  enabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: enabled ? null : Colors.orange.shade700,
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _tasksController,
        builder: (context, _) {
          final tasksState = _tasksController.state;

          return Padding(
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
                      onPressed: () => _tasksController
                          .setSearchTag(_searchTagController.text),
                      icon: const Icon(Icons.search),
                    ),
                  ),
                  onSubmitted: _tasksController.setSearchTag,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: tasksState.statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status filter',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All statuses')),
                          DropdownMenuItem(
                              value: 'todo', child: Text('To do')),
                          DropdownMenuItem(
                              value: 'in_progress',
                              child: Text('In progress')),
                          DropdownMenuItem(
                              value: 'done', child: Text('Done')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _tasksController.setStatusFilter(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: tasksState.categoryFilter,
                        decoration: const InputDecoration(
                          labelText: 'Category filter',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'all',
                              child: Text('All categories')),
                          DropdownMenuItem(
                              value: 'general', child: Text('General')),
                          DropdownMenuItem(
                              value: 'study', child: Text('Study')),
                          DropdownMenuItem(
                              value: 'work', child: Text('Work')),
                          DropdownMenuItem(
                              value: 'personal',
                              child: Text('Personal')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _tasksController.setCategoryFilter(value);
                          }
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
                      _tasksController.clearFilters();
                    },
                    child: const Text('Clear filters'),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(child: _buildTaskList(tasksState)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: TaskPageKeys.addFab,
        onPressed: _openCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
    );
  }

  Widget _buildTaskList(TasksState tasksState) {
    if (tasksState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(key: TaskPageKeys.loadingIndicator),
      );
    }

    if (tasksState.errorMessage != null && tasksState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              key: TaskPageKeys.errorText,
              tasksState.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 10),
            FilledButton(
              key: TaskPageKeys.retryButton,
              onPressed: _tasksController.loadTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (tasksState.items.isEmpty) {
      return const Center(
        child: Text(
          'No tasks yet. Add your first task.',
          key: TaskPageKeys.emptyState,
        ),
      );
    }

    return ListView.builder(
      key: TaskPageKeys.listView,
      itemCount:
          tasksState.items.length + (tasksState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == tasksState.items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: tasksState.isLoadingMore
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: _tasksController.loadMore,
                      child: const Text('Load 10 more'),
                    ),
            ),
          );
        }

        final task = tasksState.items[index];
        return Card(
          child: ListTile(
            key: TaskPageKeys.taskTile(task.id),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => widget.taskDetailsPageBuilder
                          ?.call(task.id) ??
                      TaskDetailsScreen(taskId: task.id),
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
                        label:
                            Text('Category: ${task.category}')),
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
  }
}

class _TaskEditorDialog extends StatefulWidget {
  const _TaskEditorDialog(
      {required this.tasksController, this.task});

  final Task? task;
  final TasksController tasksController;

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
    _titleController =
        TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _tagsController =
        TextEditingController(text: task?.tags.join(', ') ?? '');
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

    final controller = widget.tasksController;
    final currentTask = widget.task;
    bool success;

    if (currentTask == null) {
      success = await controller.addTask(
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        category: _category,
        tagsRaw: _tagsController.text,
      );
    } else {
      success = await controller.updateTask(
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
    if (success) {
      Navigator.of(context).pop(true);
    }
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
                key: TaskPageKeys.titleField,
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
                      (status) => DropdownMenuItem(
                          value: status, child: Text(status)),
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
                          value: category, child: Text(category)),
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
          key: TaskPageKeys.submitButton,
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
