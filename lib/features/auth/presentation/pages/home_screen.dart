import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../auth/presentation/state/auth_state.dart';
import 'user_settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _signOut() async {
    Navigator.of(context).pop();
    await context.read<AuthController>().signOut();
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
                          user?.photoUrl != null && user!.photoUrl!.isNotEmpty
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
          appBar: AppBar(title: const Text('Home')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_outlined, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      displayName != null && displayName.isNotEmpty
                          ? 'Welcome, $displayName'
                          : 'Welcome',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the drawer to open profile settings or sign out.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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
  }
}
