import 'package:firebase_auth/firebase_auth.dart';

/// Wraps FirebaseAuth to expose typed results that the UI can use.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes (null = signed out, non-null = signed in)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current signed-in user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  /// Returns a [LoginResult] so the UI can display errors without exceptions.
  Future<LoginResult> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const LoginResult(success: true);
    } on FirebaseAuthException catch (e) {
      return LoginResult(success: false, errorMessage: _mapError(e));
    } catch (_) {
      return const LoginResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign up with email, password, and name.
  Future<LoginResult> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      return const LoginResult(success: true);
    } on FirebaseAuthException catch (e) {
      return LoginResult(success: false, errorMessage: _mapError(e));
    } catch (_) {
      return const LoginResult(
        success: false,
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Maps FirebaseAuthException codes to user-friendly messages.
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }
}

/// Result returned from auth operations — same shape as the old mock.
class LoginResult {
  final bool success;
  final String? errorMessage;
  const LoginResult({required this.success, this.errorMessage});
}
