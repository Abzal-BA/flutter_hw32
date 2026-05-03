import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../../tasks/presentation/controller/tasks_controller.dart';
import '../../../tasks/presentation/pages/task_edit_page.dart';
import '../../../tasks/presentation/state/tasks_state.dart';
import 'user_settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<TasksController>().loadTasks();
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    Navigator.of(context).pop();
    await context.read<AuthController>().signOut();
  }

  Future<void> _addTask() async {
    await context.read<TasksController>().addTask(_taskController.text);
    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();
    final tasksController = context.read<TasksController>();

    return StreamBuilder<AuthState>(
      stream: authController.stream,
      initialData: authController.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();
        final user = state.user;

        final displayName = user?.displayName?.trim();

        return AnimatedBuilder(
          animation: tasksController,
          builder: (context, _) {
            final tasksState = tasksController.state;
            return Scaffold(
              drawer: Drawer(
                child: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(
                          displayName != null && displayName.isNotEmpty
                              ? displayName
                              : 'User without display name',
                        ),
                        accountEmail: Text(user?.email ?? 'No email'),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage:
                              user?.photoUrl != null &&
                                  user!.photoUrl!.isNotEmpty
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child:
                              user?.photoUrl == null || user!.photoUrl!.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      ListTile(
                        key: const ValueKey<String>('drawerProfileButton'),
                        leading: const Icon(Icons.settings),
                        title: const Text('Profile settings'),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const UserSettingsPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        key: const ValueKey<String>('drawerSignOutButton'),
                        leading: const Icon(Icons.logout),
                        title: const Text('Sign out'),
                        onTap: _signOut,
                      ),
                    ],
                  ),
                ),
              ),
              appBar: AppBar(title: const Text('Task Manager')),
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          displayName != null && displayName.isNotEmpty
                              ? 'Welcome, $displayName'
                              : 'Welcome',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your current tasks from the main page.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _taskController,
                          decoration: const InputDecoration(
                            labelText: 'New task',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: tasksState.isSaving ? null : _addTask,
                          child: tasksState.isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Add task'),
                        ),
                        const SizedBox(height: 20),
                        _TasksSection(tasksState: tasksState),
                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TasksSection extends StatelessWidget {
  const _TasksSection({required this.tasksState});

  final TasksState tasksState;

  @override
  Widget build(BuildContext context) {
    if (tasksState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (tasksState.errorMessage != null) {
      return Text(
        tasksState.errorMessage!,
        style: TextStyle(color: Colors.red.shade700),
      );
    }
    if (tasksState.items.isEmpty) {
      return const Text('No current tasks yet.');
    }

    return Column(
      children: tasksState.items
          .map(
            (task) => Card(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TaskEditPage(task: task)),
                  );
                },
                title: Text(task.title),
                subtitle: Text(
                  'Status: ${_labelForStatus(task.status)}\n${task.createdAt.toLocal().toIso8601String()}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          )
          .toList(growable: false),
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
