import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isBusy = false,
    this.isLoginMode = true,
    this.isAuthReady = false,
    this.errorMessage,
    this.infoMessage,
  });

  static const Object _unset = Object();

  final User? user;
  final bool isBusy;
  final bool isLoginMode;
  final bool isAuthReady;
  final String? errorMessage;
  final String? infoMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Object? user = _unset,
    bool? isBusy,
    bool? isLoginMode,
    bool? isAuthReady,
    Object? errorMessage = _unset,
    Object? infoMessage = _unset,
  }) {
    return AuthState(
      user: identical(user, _unset) ? this.user : user as User?,
      isBusy: isBusy ?? this.isBusy,
      isLoginMode: isLoginMode ?? this.isLoginMode,
      isAuthReady: isAuthReady ?? this.isAuthReady,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      infoMessage: identical(infoMessage, _unset)
          ? this.infoMessage
          : infoMessage as String?,
    );
  }
}
