import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_cubit.dart';
import 'auth/auth_state.dart';
import 'di/service_locator.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Task: Initialize Firebase for auth features.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupDependencies();

  runApp(
    Provider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      dispose: (_, cubit) => cubit.close(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Day 32 Auth HW',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    // Task: authStateChanges() automatically switches login/home screens.
    return StreamBuilder<AuthState>(
      stream: authCubit.stream,
      initialData: authCubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();
        if (!state.isAuthReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.isAuthenticated) {
          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus();
    final authCubit = context.read<AuthCubit>();

    // Task: Email/password login and registration through Cubit.
    await authCubit.submitWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim(),
    );
  }

  Future<void> _forgotPassword() async {
    // Task: Forgot password flow from auth screen.
    await context.read<AuthCubit>().sendPasswordReset(_emailController.text);
  }

  Future<void> _signInWithGoogle() async {
    // Task: Google Sign-In via Cubit.
    await context.read<AuthCubit>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return StreamBuilder<AuthState>(
      stream: authCubit.stream,
      initialData: authCubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();

        if (state.infoMessage != null && state.infoMessage!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.infoMessage!)),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(state.isLoginMode ? 'Login' : 'Register'),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!state.isLoginMode)
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (state.isLoginMode) return null;
                            if ((value ?? '').trim().length < 2) {
                              return 'Display name must be at least 2 characters.';
                            }
                            return null;
                          },
                        ),
                      if (!state.isLoginMode) const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty || !text.contains('@')) {
                            return 'Enter a valid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.length < 6) {
                            return 'Password must be at least 6 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      if (state.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      if (state.errorMessage != null) const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: state.isBusy ? null : _submit,
                        child: state.isBusy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(state.isLoginMode ? 'Login' : 'Create account'),
                      ),
                      TextButton(
                        onPressed: state.isBusy ? null : authCubit.toggleAuthMode,
                        child: Text(
                          state.isLoginMode
                              ? 'No account? Register'
                              : 'Already have an account? Login',
                        ),
                      ),
                      TextButton(
                        onPressed: state.isBusy ? null : _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                      OutlinedButton.icon(
                        onPressed: state.isBusy ? null : _signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
    await context.read<AuthCubit>().updateDisplayName(_nameController.text);
  }

  Future<void> _signOut() async {
    // Task: Logout support and route protection via AuthGate.
    await context.read<AuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return StreamBuilder<AuthState>(
      stream: authCubit.stream,
      initialData: authCubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();
        final user = state.user;

        final displayName = user?.displayName?.trim();
        final email = user?.email ?? 'No email';
        final photoUrl = user?.photoURL;

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
                    // Task: Display user profile (displayName/photoURL) on home screen.
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
                    if (state.errorMessage != null) const SizedBox(height: 8),
                    if (state.errorMessage != null)
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    if (state.infoMessage != null) const SizedBox(height: 8),
                    if (state.infoMessage != null)
                      Text(
                        state.infoMessage!,
                        textAlign: TextAlign.center,
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
