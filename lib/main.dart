import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_state.dart';
import 'di/service_locator.dart';
import 'firebase_options.dart';
import 'notifications/notification_service.dart';
import 'pages/auth_screen.dart';
import 'pages/task_page.dart';

const day35TaskImplementationMap = <String, List<String>>{
  '1. MVC task screen': <String>[
    'lib/pages/task_page.dart',
    'lib/notes/notes_controller.dart',
    'lib/notes/notes_repository.dart',
  ],
  '2. MVP task screen + comparison': <String>[
    'lib/pages/task_page_mvp.dart',
    'lib/notes/mvp/notes_presenter.dart',
    'docs/day35_manual_test.md',
  ],
  '3. Business logic out of UI (load/add) + manual test': <String>[
    'lib/notes/notes_controller.dart',
    'lib/notes/mvp/notes_presenter.dart',
    'docs/day35_manual_test.md',
  ],
  '4. Layer diagram + responsibilities': <String>[
    'docs/day35_layers.md',
  ],
  '5. Unified error handling': <String>[
    'lib/core/error_handler.dart',
    'lib/notes/notes_controller.dart',
    'lib/notes/mvp/notes_presenter.dart',
    'lib/auth/auth_controller.dart',
  ],
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();

  runApp(
    ChangeNotifierProvider<AuthController>(
      create: (_) => getIt<AuthController>(),
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
    final authController = context.read<AuthController>();

    return StreamBuilder<AuthState>(
      stream: authController.stream,
      initialData: authController.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const AuthState();
        if (!state.isAuthReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.isAuthenticated) {
          return const TaskPage();
        }

        return const AuthScreen();
      },
    );
  }
}
