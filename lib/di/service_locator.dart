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
import '../features/comments/data/datasources/comment_remote_datasource.dart';
import '../features/comments/data/repositories/comment_repository_impl.dart';
import '../features/comments/domain/repositories/i_comment_repository.dart';
import '../features/comments/domain/usecases/add_comment_usecase.dart';
import '../features/comments/domain/usecases/delete_comment_usecase.dart';
import '../features/comments/domain/usecases/watch_comments_usecase.dart';
import '../features/notifications/notification_service.dart';
import '../features/notifications/notification_settings_store.dart';
import '../features/tasks/data/datasources/task_remote_datasource.dart';
import '../features/tasks/data/repositories/task_repository_impl.dart';
import '../features/tasks/domain/repositories/i_task_repository.dart';
import '../features/tasks/domain/usecases/add_task_usecase.dart';
import '../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../features/tasks/domain/usecases/update_task_usecase.dart';
import '../features/tasks/domain/usecases/watch_task_usecase.dart';
import '../features/tasks/domain/usecases/watch_tasks_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }
  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance);
  }
  if (!getIt.isRegistered<GoogleSignIn>()) {
    getIt.registerLazySingleton<GoogleSignIn>(GoogleSignIn.new);
  }
  if (!getIt.isRegistered<FirebaseMessaging>()) {
    getIt.registerLazySingleton<FirebaseMessaging>(
        () => FirebaseMessaging.instance);
  }
  if (!getIt.isRegistered<FlutterLocalNotificationsPlugin>()) {
    getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
        FlutterLocalNotificationsPlugin.new);
  }
  if (!getIt.isRegistered<SharedPreferences>()) {
    final preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(preferences);
  }

  if (!getIt.isRegistered<NotificationSettingsStore>()) {
    getIt.registerLazySingleton<NotificationSettingsStore>(
        () => NotificationSettingsStore(getIt<SharedPreferences>()));
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

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        auth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
      ),
    );
  }
  if (!getIt.isRegistered<IAuthRepository>()) {
    getIt.registerLazySingleton<IAuthRepository>(
        () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()));
  }
  if (!getIt.isRegistered<SignInWithEmailUseCase>()) {
    getIt.registerLazySingleton<SignInWithEmailUseCase>(
        () => SignInWithEmailUseCase(getIt<IAuthRepository>()));
  }
  if (!getIt.isRegistered<RegisterWithEmailUseCase>()) {
    getIt.registerLazySingleton<RegisterWithEmailUseCase>(
        () => RegisterWithEmailUseCase(getIt<IAuthRepository>()));
  }
  if (!getIt.isRegistered<SignOutUseCase>()) {
    getIt.registerLazySingleton<SignOutUseCase>(
        () => SignOutUseCase(getIt<IAuthRepository>()));
  }
  if (!getIt.isRegistered<SendPasswordResetUseCase>()) {
    getIt.registerLazySingleton<SendPasswordResetUseCase>(
        () => SendPasswordResetUseCase(getIt<IAuthRepository>()));
  }
  if (!getIt.isRegistered<SignInWithGoogleUseCase>()) {
    getIt.registerLazySingleton<SignInWithGoogleUseCase>(
        () => SignInWithGoogleUseCase(getIt<IAuthRepository>()));
  }
  if (!getIt.isRegistered<UpdateDisplayNameUseCase>()) {
    getIt.registerLazySingleton<UpdateDisplayNameUseCase>(
        () => UpdateDisplayNameUseCase(getIt<IAuthRepository>()));
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

  if (!getIt.isRegistered<TaskRemoteDataSource>()) {
    getIt.registerLazySingleton<TaskRemoteDataSource>(
        () => TaskRemoteDataSource(getIt<FirebaseFirestore>()));
  }
  if (!getIt.isRegistered<ITaskRepository>()) {
    getIt.registerLazySingleton<ITaskRepository>(
        () => TaskRepositoryImpl(getIt<TaskRemoteDataSource>()));
  }
  if (!getIt.isRegistered<WatchTasksUseCase>()) {
    getIt.registerLazySingleton<WatchTasksUseCase>(
        () => WatchTasksUseCase(getIt<ITaskRepository>()));
  }
  if (!getIt.isRegistered<WatchTaskUseCase>()) {
    getIt.registerLazySingleton<WatchTaskUseCase>(
        () => WatchTaskUseCase(getIt<ITaskRepository>()));
  }
  if (!getIt.isRegistered<AddTaskUseCase>()) {
    getIt.registerLazySingleton<AddTaskUseCase>(
        () => AddTaskUseCase(getIt<ITaskRepository>()));
  }
  if (!getIt.isRegistered<UpdateTaskUseCase>()) {
    getIt.registerLazySingleton<UpdateTaskUseCase>(
        () => UpdateTaskUseCase(getIt<ITaskRepository>()));
  }
  if (!getIt.isRegistered<DeleteTaskUseCase>()) {
    getIt.registerLazySingleton<DeleteTaskUseCase>(
        () => DeleteTaskUseCase(getIt<ITaskRepository>()));
  }

  if (!getIt.isRegistered<CommentRemoteDataSource>()) {
    getIt.registerLazySingleton<CommentRemoteDataSource>(
        () => CommentRemoteDataSource(getIt<FirebaseFirestore>()));
  }
  if (!getIt.isRegistered<ICommentRepository>()) {
    getIt.registerLazySingleton<ICommentRepository>(
        () => CommentRepositoryImpl(getIt<CommentRemoteDataSource>()));
  }
  if (!getIt.isRegistered<WatchCommentsUseCase>()) {
    getIt.registerLazySingleton<WatchCommentsUseCase>(
        () => WatchCommentsUseCase(getIt<ICommentRepository>()));
  }
  if (!getIt.isRegistered<AddCommentUseCase>()) {
    getIt.registerLazySingleton<AddCommentUseCase>(
        () => AddCommentUseCase(getIt<ICommentRepository>()));
  }
  if (!getIt.isRegistered<DeleteCommentUseCase>()) {
    getIt.registerLazySingleton<DeleteCommentUseCase>(
        () => DeleteCommentUseCase(getIt<ICommentRepository>()));
  }
}
