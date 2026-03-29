import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_controller.dart';
import '../core/error_handler.dart';
import '../notifications/notification_service.dart';
import '../notifications/notification_settings_store.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  if (!getIt.isRegistered<GoogleSignIn>()) {
    getIt.registerLazySingleton<GoogleSignIn>(GoogleSignIn.new);
  }

  if (!getIt.isRegistered<FirebaseMessaging>()) {
    getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  }

  if (!getIt.isRegistered<FlutterLocalNotificationsPlugin>()) {
    getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin.new,
    );
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    final preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(preferences);
  }

  if (!getIt.isRegistered<NotificationSettingsStore>()) {
    getIt.registerLazySingleton<NotificationSettingsStore>(
      () => NotificationSettingsStore(getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<NotificationService>()) {
    getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(
        messaging: getIt<FirebaseMessaging>(),
        localNotifications: getIt<FlutterLocalNotificationsPlugin>(),
        auth: getIt<FirebaseAuth>(),
        firestore: getIt<FirebaseFirestore>(),
        settingsStore: getIt<NotificationSettingsStore>(),
      ),
    );
  }

  if (!getIt.isRegistered<AppErrorHandler>()) {
    getIt.registerLazySingleton<AppErrorHandler>(AppErrorHandler.new);
  }

  if (!getIt.isRegistered<AuthController>()) {
    getIt.registerFactory<AuthController>(
      () => AuthController(
        auth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
        errorHandler: getIt<AppErrorHandler>(),
      ),
    );
  }

}
