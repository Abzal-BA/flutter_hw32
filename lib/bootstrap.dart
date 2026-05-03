import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_environment.dart';
import 'di/service_locator.dart';
import 'features/auth/presentation/controller/auth_controller.dart';
import 'features/auth/presentation/pages/auth_screen.dart';
import 'features/auth/presentation/pages/home_screen.dart';
import 'features/auth/presentation/state/auth_state.dart';
import 'features/notifications/notification_service.dart';
import 'features/tasks/presentation/controller/tasks_controller.dart';
import 'firebase_options.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();

  final environment = AppEnvironment.fromFlavor(flavor);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
          create: (_) => getIt<AuthController>(),
        ),
        ChangeNotifierProvider<TasksController>(
          create: (_) => getIt<TasksController>(),
        ),
      ],
      child: MainApp(environment: environment),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({required this.environment, super.key});

  final AppEnvironment environment;

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
    final environment = widget.environment;

    return MaterialApp(
      navigatorKey: getIt<NotificationService>().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: environment.appTitle,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      builder: (context, child) {
        if (child == null || !environment.showBanner) {
          return child ?? const SizedBox.shrink();
        }

        return Banner(
          message: environment.bannerLabel,
          location: BannerLocation.topStart,
          child: child,
        );
      },
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
          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
