import '../entities/auth_user.dart';

abstract class IAuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> get authStateChanges;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signInWithGoogle();

  Future<void> updateDisplayName(String displayName);

  Future<void> signOut();
}
