import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_cubit.dart';
import 'auth/auth_state.dart';
import 'di/service_locator.dart';
import 'firebase_options.dart';
import 'notifications/notification_service.dart';
import 'pages/auth_screen.dart';
import 'pages/task_page.dart';

/* Home work day 34 - Notifications
 Notification tasks map (implemented in project):
 1) Send test notification and open Notification Details from payload tap.
 2) Foreground local notification display and tap navigation.
 3) Save device token to Firestore and refresh it on token changes.
 4) Notification settings screen (enable/disable) with local persisted flag.
 5) Deep link handling: open a specific item by id from payload.
 6) Logging for notification receive/open events.

 See implementation in notification modules:
 - lib/notifications/notification_service.dart
 - lib/notifications/notification_settings_screen.dart
 - lib/notifications/notification_details_screen.dart
 - lib/notifications/task_details_screen.dart
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();

  runApp(
    Provider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      dispose: (_, cubit) => cubit.close(),
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
      // Initializes handlers for foreground/background/open/tap notification flows.
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
    final authCubit = context.read<AuthCubit>();

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
          return const TaskPage();
        }

        return const AuthScreen();
      },
    );
  }
}
