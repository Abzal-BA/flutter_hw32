import 'package:flutter_hw32/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_hw32/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isAuthenticated is true when user exists', () {
    const state = AuthState(user: AuthUser(uid: 'user-1'));

    expect(state.isAuthenticated, isTrue);
  });

  test('copyWith clears messages when requested', () {
    const initial = AuthState(
      errorMessage: 'error',
      infoMessage: 'info',
      isAuthReady: true,
    );

    final updated = initial.copyWith(clearError: true, clearInfo: true);

    expect(updated.errorMessage, isNull);
    expect(updated.infoMessage, isNull);
    expect(updated.isAuthReady, isTrue);
  });
}
