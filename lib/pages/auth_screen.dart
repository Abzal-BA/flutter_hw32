import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';

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
    final authController = context.read<AuthController>();

    await authController.submitWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim(),
    );
  }

  Future<void> _forgotPassword() async {
    await context.read<AuthController>().sendPasswordReset(_emailController.text);
  }

  Future<void> _signInWithGoogle() async {
    await context.read<AuthController>().signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();

    return StreamBuilder<AuthState>(
      stream: authController.stream,
      initialData: authController.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();

        if (state.infoMessage != null && state.infoMessage!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.infoMessage!)));
          });
        }

        return Scaffold(
          appBar: AppBar(title: Text(state.isLoginMode ? 'Login' : 'Register')),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                state.isLoginMode ? 'Login' : 'Create account',
                              ),
                      ),
                      TextButton(
                        onPressed: state.isBusy ? null : authController.toggleAuthMode,
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
