import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/app_error_handler.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/register_with_email_usecase.dart';
import '../../domain/usecases/send_password_reset_usecase.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/update_display_name_usecase.dart';
import '../state/auth_state.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required IAuthRepository authRepository,
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required RegisterWithEmailUseCase registerWithEmailUseCase,
    required SignOutUseCase signOutUseCase,
    required SendPasswordResetUseCase sendPasswordResetUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required UpdateDisplayNameUseCase updateDisplayNameUseCase,
    required AppErrorHandler errorHandler,
  })  : _authRepository = authRepository,
        _signInWithEmailUseCase = signInWithEmailUseCase,
        _registerWithEmailUseCase = registerWithEmailUseCase,
        _signOutUseCase = signOutUseCase,
        _sendPasswordResetUseCase = sendPasswordResetUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _updateDisplayNameUseCase = updateDisplayNameUseCase,
        _errorHandler = errorHandler,
        _state = AuthState(
          user: authRepository.currentUser,
          isAuthReady: true,
          isBusy: false,
          isLoginMode: true,
        ) {
    _authSubscription =
        _authRepository.authStateChanges.listen(_handleAuthChanged);
  }

  final IAuthRepository _authRepository;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final RegisterWithEmailUseCase _registerWithEmailUseCase;
  final SignOutUseCase _signOutUseCase;
  final SendPasswordResetUseCase _sendPasswordResetUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final UpdateDisplayNameUseCase _updateDisplayNameUseCase;
  final AppErrorHandler _errorHandler;

  StreamSubscription<AuthUser?>? _authSubscription;
  AuthState _state;

  AuthState get state => _state;

  void _emit(AuthState value) {
    _state = value;
    notifyListeners();
  }

  void _handleAuthChanged(AuthUser? user) {
    _emit(state.copyWith(
      user: user,
      isAuthReady: true,
      isBusy: false,
      clearError: true,
    ));
  }

  void toggleAuthMode() {
    _emit(state.copyWith(
      isLoginMode: !state.isLoginMode,
      clearError: true,
      clearInfo: true,
    ));
  }

  void clearInfoMessage() {
    if (state.infoMessage == null) return;
    _emit(state.copyWith(clearInfo: true));
  }

  Future<void> submitWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _emit(state.copyWith(isBusy: true, clearError: true, clearInfo: true));

    try {
      if (state.isLoginMode) {
        await _signInWithEmailUseCase.call(
          SignInWithEmailParams(email: email, password: password),
        );
      } else {
        await _registerWithEmailUseCase.call(
          RegisterWithEmailParams(
            email: email,
            password: password,
            displayName: displayName,
          ),
        );
      }
    } catch (error) {
      _emit(state.copyWith(
        errorMessage: _errorHandler.toMessage(
          error,
          fallback: 'Unexpected error. Please try again.',
        ),
      ));
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final safeEmail = email.trim();
    if (safeEmail.isEmpty) {
      _emit(state.copyWith(
        errorMessage: 'Enter your email first to reset password.',
      ));
      return;
    }

    _emit(state.copyWith(isBusy: true, clearError: true, clearInfo: true));

    try {
      await _sendPasswordResetUseCase.call(safeEmail);
      _emit(state.copyWith(
        infoMessage: 'Password reset email sent to $safeEmail',
      ));
    } catch (error) {
      _emit(state.copyWith(
        errorMessage: _errorHandler.toMessage(
          error,
          fallback: 'Password reset failed. Please try again.',
        ),
      ));
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> signInWithGoogle() async {
    _emit(state.copyWith(isBusy: true, clearError: true, clearInfo: true));

    try {
      await _signInWithGoogleUseCase.call();
    } catch (error) {
      _emit(state.copyWith(
        errorMessage: _errorHandler.toMessage(
          error,
          fallback: 'Google sign-in failed. Check Firebase configuration.',
        ),
      ));
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      _emit(state.copyWith(
        errorMessage: 'You must be signed in to update profile.',
      ));
      return;
    }

    final safeName = displayName.trim();
    if (safeName.isEmpty) {
      _emit(state.copyWith(errorMessage: 'Enter a name first.'));
      return;
    }

    _emit(state.copyWith(isBusy: true, clearError: true, clearInfo: true));

    try {
      await _updateDisplayNameUseCase.call(safeName);
      _emit(state.copyWith(
        user: _authRepository.currentUser,
        infoMessage: 'Profile updated successfully.',
      ));
    } catch (error) {
      _emit(state.copyWith(
        errorMessage: _errorHandler.toMessage(
          error,
          fallback: 'Failed to update profile.',
        ),
      ));
    } finally {
      _emit(state.copyWith(isBusy: false));
    }
  }

  Future<void> signOut() => _signOutUseCase.call();

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }
}