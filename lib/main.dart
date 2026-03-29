import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'di/service_locator.dart';
import 'features/auth/presentation/pages/auth_screen.dart';
import 'features/auth/presentation/viewmodel/auth_view_model.dart';
import 'features/notifications/notification_service.dart';
import 'features/tasks/presentation/pages/task_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();

  runApp(
    ChangeNotifierProvider<AuthViewModel>(
      create: (_) => getIt<AuthViewModel>(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    unawaited(_initializeNotifications());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<NotificationService>().flushPendingNavigation();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      await getIt<NotificationService>().initialize();
      if (!mounted) {
        return;
      }
      getIt<NotificationService>().flushPendingNavigation();
    } catch (error, stackTrace) {
      debugPrint('Notification initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: getIt<NotificationService>().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Day 34 Notifications HW',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthViewModel>().state;

    if (!state.isAuthReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.isAuthenticated) {
      return const TaskPage();
    }

    return const AuthScreen();
  }
}
