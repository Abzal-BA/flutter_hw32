import '../../domain/entities/auth_user.dart';

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

  final AuthUser? user;
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
    bool clearError = false,
    Object? infoMessage = _unset,
    bool clearInfo = false,
  }) {
    return AuthState(
      user: identical(user, _unset) ? this.user : user as AuthUser?,
      isBusy: isBusy ?? this.isBusy,
      isLoginMode: isLoginMode ?? this.isLoginMode,
      isAuthReady: isAuthReady ?? this.isAuthReady,
      errorMessage: clearError
          ? null
          : (identical(errorMessage, _unset)
                ? this.errorMessage
                : errorMessage as String?),
      infoMessage: clearInfo
          ? null
          : (identical(infoMessage, _unset)
                ? this.infoMessage
                : infoMessage as String?),
    );
  }
}
