import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/viewmodel/auth_view_model.dart';
import '../../../tasks/presentation/pages/task_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateDisplayName() async {
    await context.read<AuthViewModel>().updateDisplayName(_nameController.text);
  }

  Future<void> _signOut() async {
    await context.read<AuthViewModel>().signOut();
  }

  Future<void> _openTaskPage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TaskPage()));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthViewModel>().state;
    final user = state.user;
    final displayName = user?.displayName?.trim();
    final email = user?.email ?? 'No email';
    final photoUrl = user?.photoUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _signOut,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 42)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  displayName != null && displayName.isNotEmpty
                      ? displayName
                      : 'User without display name',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'New display name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: state.isBusy ? null : _updateDisplayName,
                  child: state.isBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save profile name'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _openTaskPage,
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Open Task Page'),
                ),
                if (state.errorMessage != null) const SizedBox(height: 8),
                if (state.errorMessage != null)
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                if (state.infoMessage != null) const SizedBox(height: 8),
                if (state.infoMessage != null)
                  Text(state.infoMessage!, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
