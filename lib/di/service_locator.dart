import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../auth/auth_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!getIt.isRegistered<GoogleSignIn>()) {
    getIt.registerLazySingleton<GoogleSignIn>(GoogleSignIn.new);
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(
      () => AuthCubit(
        auth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
      ),
    );
  }
}
