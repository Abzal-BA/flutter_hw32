import 'package:firebase_auth/firebase_auth.dart';

String mapFirebaseAuthError(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'The email address is invalid.';
    case 'user-disabled':
      return 'This user account has been disabled.';
    case 'user-not-found':
      return 'No user found for this email.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'This email is already in use.';
    case 'weak-password':
      return 'Password is too weak.';
    case 'too-many-requests':
      return 'Too many requests. Try again later.';
    case 'network-request-failed':
      return 'Network error. Check your internet connection.';
    case 'operation-not-allowed':
      return 'This auth method is not enabled in Firebase.';
    default:
      return error.message ?? 'Authentication error occurred.';
  }
}
