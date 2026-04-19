import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/error/app_error_handler.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/i_auth_repository.dart';
import '../features/auth/domain/usecases/register_with_email_usecase.dart';
import '../features/auth/domain/usecases/send_password_reset_usecase.dart';
import '../features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../features/auth/domain/usecases/sign_out_usecase.dart';
import '../features/auth/domain/usecases/update_display_name_usecase.dart';
import '../features/auth/presentation/controller/auth_controller.dart';
import '../features/items/data/api_client.dart';
import '../features/items/data/fake_server_api_client.dart';
import '../features/items/data/in_memory_items_db.dart';
import '../features/items/data/item_repository_impl.dart';
import '../features/items/data/items_db.dart';
import '../features/items/domain/i_item_repository.dart';
import '../features/items/presentation/controller/items_controller.dart';
import '../features/notifications/notification_service.dart';
import '../features/notifications/notification_settings_store.dart';

final GetIt getIt = GetIt.instance;

class DependencyOverrides {
  const DependencyOverrides({
    this.authRepository,
    this.apiClient,
    this.itemsDb,
    this.itemRepository,
  });

  final IAuthRepository? authRepository;
  final ApiClient? apiClient;
  final ItemsDb? itemsDb;
  final IItemRepository? itemRepository;
}

Future<void> resetDependencies() async {
  await getIt.reset();
}

Future<void> setupDependencies({
  DependencyOverrides overrides = const DependencyOverrides(),
  bool registerNotifications = true,
}) async {
  if (!getIt.isRegistered<FirebaseAuth>() && overrides.authRepository == null) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }
  if (!getIt.isRegistered<FirebaseFirestore>() && registerNotifications) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }
  if (!getIt.isRegistered<GoogleSignIn>() && overrides.authRepository == null) {
    getIt.registerLazySingleton<GoogleSignIn>(GoogleSignIn.new);
  }
  if (!getIt.isRegistered<FirebaseMessaging>() && registerNotifications) {
    getIt.registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance,
    );
  }
  if (!getIt.isRegistered<FlutterLocalNotificationsPlugin>() &&
      registerNotifications) {
    getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin.new,
    );
  }
  if (!getIt.isRegistered<SharedPreferences>() && registerNotifications) {
    final preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(preferences);
  }

  if (!getIt.isRegistered<NotificationSettingsStore>() &&
      registerNotifications) {
    getIt.registerLazySingleton<NotificationSettingsStore>(
      () => NotificationSettingsStore(getIt<SharedPreferences>()),
    );
  }
  if (!getIt.isRegistered<NotificationService>() && registerNotifications) {
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

  if (overrides.authRepository != null &&
      !getIt.isRegistered<IAuthRepository>()) {
    getIt.registerSingleton<IAuthRepository>(overrides.authRepository!);
  }
  if (!getIt.isRegistered<AuthRemoteDataSource>() &&
      overrides.authRepository == null) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        auth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
      ),
    );
  }
  if (!getIt.isRegistered<IAuthRepository>()) {
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
  }

  if (overrides.apiClient != null && !getIt.isRegistered<ApiClient>()) {
    getIt.registerSingleton<ApiClient>(overrides.apiClient!);
  }
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(FakeServerApiClient.new);
  }

  if (overrides.itemsDb != null && !getIt.isRegistered<ItemsDb>()) {
    getIt.registerSingleton<ItemsDb>(overrides.itemsDb!);
  }
  if (!getIt.isRegistered<ItemsDb>()) {
    getIt.registerLazySingleton<ItemsDb>(InMemoryItemsDb.new);
  }

  if (overrides.itemRepository != null &&
      !getIt.isRegistered<IItemRepository>()) {
    getIt.registerSingleton<IItemRepository>(overrides.itemRepository!);
  }
  if (!getIt.isRegistered<IItemRepository>()) {
    getIt.registerLazySingleton<IItemRepository>(
      () => ItemRepositoryImpl(
        apiClient: getIt<ApiClient>(),
        db: getIt<ItemsDb>(),
      ),
    );
  }

  if (!getIt.isRegistered<SignInWithEmailUseCase>()) {
    getIt.registerLazySingleton<SignInWithEmailUseCase>(
      () => SignInWithEmailUseCase(getIt<IAuthRepository>()),
    );
  }
  if (!getIt.isRegistered<RegisterWithEmailUseCase>()) {
    getIt.registerLazySingleton<RegisterWithEmailUseCase>(
      () => RegisterWithEmailUseCase(getIt<IAuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SignOutUseCase>()) {
    getIt.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(getIt<IAuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SendPasswordResetUseCase>()) {
    getIt.registerLazySingleton<SendPasswordResetUseCase>(
      () => SendPasswordResetUseCase(getIt<IAuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SignInWithGoogleUseCase>()) {
    getIt.registerLazySingleton<SignInWithGoogleUseCase>(
      () => SignInWithGoogleUseCase(getIt<IAuthRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdateDisplayNameUseCase>()) {
    getIt.registerLazySingleton<UpdateDisplayNameUseCase>(
      () => UpdateDisplayNameUseCase(getIt<IAuthRepository>()),
    );
  }
  if (!getIt.isRegistered<AuthController>()) {
    getIt.registerFactory<AuthController>(
      () => AuthController(
        authRepository: getIt<IAuthRepository>(),
        signInWithEmailUseCase: getIt<SignInWithEmailUseCase>(),
        registerWithEmailUseCase: getIt<RegisterWithEmailUseCase>(),
        signOutUseCase: getIt<SignOutUseCase>(),
        sendPasswordResetUseCase: getIt<SendPasswordResetUseCase>(),
        signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
        updateDisplayNameUseCase: getIt<UpdateDisplayNameUseCase>(),
        errorHandler: getIt<AppErrorHandler>(),
      ),
    );
  }
  if (!getIt.isRegistered<ItemsController>()) {
    getIt.registerFactory<ItemsController>(
      () => ItemsController(
        itemRepository: getIt<IItemRepository>(),
        authRepository: getIt<IAuthRepository>(),
        errorHandler: getIt<AppErrorHandler>(),
      ),
    );
  }
}
