import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../auth/presentation/state/auth_state.dart';
import '../../../items/presentation/controller/items_controller.dart';
import '../../../items/presentation/pages/task_edit_page.dart';
import '../../../items/presentation/state/items_state.dart';
import 'user_settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _itemController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await context.read<AuthController>().signOut();
  }

  Future<void> _addItem() async {
    await context.read<ItemsController>().addItem(_itemController.text);
    _itemController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();
    final itemsController = context.read<ItemsController>();

    return StreamBuilder<AuthState>(
      stream: authController.stream,
      initialData: authController.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();
        final user = state.user;

        final displayName = user?.displayName?.trim();

        return AnimatedBuilder(
          animation: itemsController,
          builder: (context, _) {
            final itemsState = itemsController.state;
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
              appBar: AppBar(title: const Text('Current Tasks')),
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Manage your current tasks here.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Current Tasks',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          key: const ValueKey<String>('itemTitleField'),
                          controller: _itemController,
                          decoration: const InputDecoration(
                            labelText: 'New task',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          key: const ValueKey<String>('addItemButton'),
                          onPressed: itemsState.isAdding ? null : _addItem,
                          child: itemsState.isAdding
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Add task'),
                        ),
                        const SizedBox(height: 12),
                        _ItemsSection(itemsState: itemsState),
                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
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

class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.itemsState});

  final ItemsState itemsState;

  @override
  Widget build(BuildContext context) {
    if (itemsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (itemsState.errorMessage != null) {
      return Text(
        itemsState.errorMessage!,
        key: const ValueKey<String>('itemsErrorText'),
        style: TextStyle(color: Colors.red.shade700),
      );
    }
    if (itemsState.items.isEmpty) {
      return const Text(
        'No current tasks yet.',
        key: ValueKey<String>('emptyItemsText'),
      );
    }

    return Column(
      key: const ValueKey<String>('itemsList'),
      children: itemsState.items
          .map(
            (item) => ListTile(
              key: ValueKey<String>('itemTile_${item.id}'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TaskEditPage(item: item)),
                );
              },
              title: Text(item.title),
              subtitle: Text(
                'Status: ${_labelForStatus(item.status)}\n${item.createdAt.toLocal().toIso8601String()}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
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
