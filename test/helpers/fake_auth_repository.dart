import 'dart:async';

import 'package:flutter_hw32/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_hw32/features/auth/domain/repositories/i_auth_repository.dart';

class FakeAuthRepository implements IAuthRepository {
  FakeAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser {
    _controller = StreamController<AuthUser?>.broadcast(
      onListen: () => _controller.add(_currentUser),
    );
  }

  late final StreamController<AuthUser?> _controller;
  AuthUser? _currentUser;

  int signInCalls = 0;
  int signOutCalls = 0;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _currentUser = AuthUser(
      uid: 'user-1',
      email: email,
      displayName: displayName,
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInCalls += 1;
    _currentUser = AuthUser(
      uid: 'user-1',
      email: email,
      displayName: 'Test User',
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInWithGoogle() async {
    _currentUser = const AuthUser(
      uid: 'user-1',
      email: 'google@example.com',
      displayName: 'Google User',
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Not signed in.');
    }
    _currentUser = AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: displayName,
      photoUrl: user.photoUrl,
    );
    _controller.add(_currentUser);
  }

  Future<void> dispose() => _controller.close();
}
