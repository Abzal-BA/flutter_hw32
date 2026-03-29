import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_error_mapper.dart';
import 'auth_state.dart';
import '../firebase_options.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        super(AuthState(
          user: auth.currentUser,
          isAuthReady: true,
          isBusy: false,
          isLoginMode: true,
          errorMessage: null,
          infoMessage: null,
        )) {
    _authSubscription = _auth.authStateChanges().listen(_handleAuthChanged);
  }

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  StreamSubscription<User?>? _authSubscription;

  void _handleAuthChanged(User? user) {
    emit(
      state.copyWith(
        user: user,
        isAuthReady: true,
        isBusy: false,
        errorMessage: null,
      ),
    );
  }

  void toggleAuthMode() {
    emit(
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
    emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

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
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(errorMessage: mapFirebaseAuthError(error)));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Unexpected error. Please try again.'));
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isBusy: false));
      }
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final safeEmail = email.trim();
    if (safeEmail.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter your email first to reset password.'));
      return;
    }

    emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

    try {
      await _auth.sendPasswordResetEmail(email: safeEmail);
      emit(
        state.copyWith(
          infoMessage: 'Password reset email sent to $safeEmail',
        ),
      );
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(errorMessage: mapFirebaseAuthError(error)));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Password reset failed. Please try again.'));
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isBusy: false));
      }
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final requiresAppleClientId =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS);
      final hasAppleClientId = (options.iosClientId ?? '').isNotEmpty;

      if (requiresAppleClientId && !hasAppleClientId) {
        emit(
          state.copyWith(
            errorMessage:
                'Google Sign-In is not configured yet. Enable Google provider and OAuth client in Firebase, then run flutterfire configure again.',
          ),
        );
        return;
      }

      final account = await _googleSignIn.signIn();
      if (account == null) {
        emit(state.copyWith(errorMessage: 'Google sign-in canceled.'));
        return;
      }

      final authData = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authData.accessToken,
        idToken: authData.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      emit(state.copyWith(errorMessage: mapFirebaseAuthError(error)));
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Google sign-in failed. Check Firebase configuration.',
        ),
      );
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isBusy: false));
      }
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(state.copyWith(errorMessage: 'You must be signed in to update profile.'));
      return;
    }

    final safeName = displayName.trim();
    if (safeName.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a name first.'));
      return;
    }

    emit(state.copyWith(isBusy: true, errorMessage: null, infoMessage: null));

    try {
      await user.updateDisplayName(safeName);
      await user.reload();

      emit(
        state.copyWith(
          user: _auth.currentUser,
          infoMessage: 'Profile updated successfully.',
        ),
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to update profile.'));
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isBusy: false));
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
