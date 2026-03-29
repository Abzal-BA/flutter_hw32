import 'package:firebase_auth/firebase_auth.dart';

import 'auth_error_mapper.dart';

class AppErrorHandler {
  String toMessage(
    Object error, {
    String fallback = 'Operation failed. Please try again.',
  }) {
    if (error is FirebaseAuthException) {
      return mapFirebaseAuthError(error);
    }

    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '');
    }

    return fallback;
  }
}
