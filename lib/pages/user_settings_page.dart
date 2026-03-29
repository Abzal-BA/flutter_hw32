import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final initialName =
        context.read<AuthController>().state.user?.displayName ?? '';
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDisplayName() async {
    await context.read<AuthController>().updateDisplayName(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();

    return StreamBuilder<AuthState>(
      stream: authController.stream,
      initialData: authController.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();
        final user = state.user;
        final displayName = user?.displayName?.trim();
        final email = user?.email ?? 'No email';
        final photoUrl = user?.photoURL;

        return Scaffold(
          appBar: AppBar(title: const Text('User settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Align(
                child: CircleAvatar(
                  radius: 42,
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? const Icon(Icons.person, size: 42)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                displayName != null && displayName.isNotEmpty
                    ? displayName
                    : 'User without display name',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
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
              FilledButton(
                onPressed: state.isBusy ? null : _saveDisplayName,
                child: state.isBusy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save profile name'),
              ),
              if (state.errorMessage != null) const SizedBox(height: 10),
              if (state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              if (state.infoMessage != null) const SizedBox(height: 10),
              if (state.infoMessage != null) Text(state.infoMessage!),
            ],
          ),
        );
      },
    );
  }
}
