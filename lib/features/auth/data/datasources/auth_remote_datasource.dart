import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../firebase_options.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final safeName = (displayName ?? '').trim();
    if (safeName.isNotEmpty) {
      await credential.user?.updateDisplayName(safeName);
      await credential.user?.reload();
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signInWithGoogle() async {
    final options = DefaultFirebaseOptions.currentPlatform;
    final requiresAppleClientId =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);
    final hasAppleClientId = (options.iosClientId ?? '').isNotEmpty;

    if (requiresAppleClientId && !hasAppleClientId) {
      throw Exception(
        'Google Sign-In is not configured yet. Enable Google provider and OAuth client in Firebase, then run flutterfire configure again.',
      );
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in canceled.');
    }

    final authData = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: authData.accessToken,
      idToken: authData.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not signed in.');
    await user.updateDisplayName(displayName);
    await user.reload();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
