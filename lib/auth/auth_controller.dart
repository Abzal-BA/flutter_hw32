import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/error_handler.dart';
import '../firebase_options.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required AppErrorHandler errorHandler,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _errorHandler = errorHandler,
        _state = AuthState(
          user: auth.currentUser,
          isAuthReady: true,
          isBusy: false,
          isLoginMode: true,
          errorMessage: null,
          infoMessage: null,
        ) {
    _stateController = StreamController<AuthState>.broadcast(
      onListen: () => _stateController.add(_state),
    );
    _authSubscription = _auth.authStateChanges().listen(_handleAuthChanged);
  }

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AppErrorHandler _errorHandler;
  late final StreamController<AuthState> _stateController;
  StreamSubscription<User?>? _authSubscription;
  AuthState _state;

  AuthState get state => _state;
  Stream<AuthState> get stream => _stateController.stream;

  void _emit(AuthState value) {
    _state = value;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
    notifyListeners();
  }

  void _handleAuthChanged(User? user) {
    _emit(
      state.copyWith(
        user: user,
        isAuthReady: true,
        isBusy: false,
        errorMessage: null,
      ),
    );
  }

  void toggleAuthMode() {
    _emit(
      state.copyWith(
        isLoginMode: !state.isLoginMode,
        errorMessage: null,
        infoMessage: null,
      ),
    );
  }

  Future<void> submitWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

    try {
      if (state.isLoginMode) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
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
    } catch (error) {
      _emit(
        state.copyWith(
          errorMessage: _errorHandler.toMessage(
            error,
            fallback: 'Unexpected error. Please try again.',
          ),
        ),
      );
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final safeEmail = email.trim();
    if (safeEmail.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Enter your email first to reset password.'));
      return;
    }

    _emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

    try {
      await _auth.sendPasswordResetEmail(email: safeEmail);
      _emit(
        state.copyWith(
          infoMessage: 'Password reset email sent to $safeEmail',
        ),
      );
    } catch (error) {
      _emit(
        state.copyWith(
          errorMessage: _errorHandler.toMessage(
            error,
            fallback: 'Password reset failed. Please try again.',
          ),
        ),
      );
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> signInWithGoogle() async {
    _emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final requiresAppleClientId =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS);
      final hasAppleClientId = (options.iosClientId ?? '').isNotEmpty;

      if (requiresAppleClientId && !hasAppleClientId) {
        _emit(
          state.copyWith(
            errorMessage:
                'Google Sign-In is not configured yet. Enable Google provider and OAuth client in Firebase, then run flutterfire configure again.',
          ),
        );
        return;
      }

      final account = await _googleSignIn.signIn();
      if (account == null) {
        _emit(state.copyWith(errorMessage: 'Google sign-in canceled.'));
        return;
      }

      final authData = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authData.accessToken,
        idToken: authData.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (error) {
      _emit(
        state.copyWith(
          errorMessage: _errorHandler.toMessage(
            error,
            fallback: 'Google sign-in failed. Check Firebase configuration.',
          ),
        ),
      );
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) {
      _emit(state.copyWith(errorMessage: 'You must be signed in to update profile.'));
      return;
    }

    final safeName = displayName.trim();
    if (safeName.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Enter a name first.'));
      return;
    }

    _emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

    try {
      await user.updateDisplayName(safeName);
      await user.reload();

      _emit(
        state.copyWith(
          user: _auth.currentUser,
          infoMessage: 'Profile updated successfully.',
        ),
      );
    } catch (error) {
      _emit(
        state.copyWith(
          errorMessage: _errorHandler.toMessage(
            error,
            fallback: 'Failed to update profile.',
          ),
        ),
      );
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_stateController.close());
    super.dispose();
  }
}
