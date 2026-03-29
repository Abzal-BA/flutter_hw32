import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  AuthUser? get currentUser => _mapUser(_dataSource.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges =>
      _dataSource.authStateChanges.map(_mapUser);

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _dataSource.signInWithEmail(email: email, password: password);

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _dataSource.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

  @override
  Future<void> sendPasswordReset(String email) =>
      _dataSource.sendPasswordReset(email);

  @override
  Future<void> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<void> updateDisplayName(String displayName) =>
      _dataSource.updateDisplayName(displayName);

  @override
  Future<void> signOut() => _dataSource.signOut();
}
