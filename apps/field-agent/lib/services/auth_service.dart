import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth service for field agent authentication.
/// Supports anonymous sign-in for rapid deployment and Google Sign-In for production.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user.
  User? get currentUser => _auth.currentUser;

  /// Get current user ID (or 'anonymous' as fallback).
  String get userId => _auth.currentUser?.uid ?? 'anonymous';

  /// Stream auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in anonymously (for rapid field deployment).
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      return null;
    }
  }

  /// Sign in with email/password (for registered agents).
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if user is authenticated.
  bool get isAuthenticated => _auth.currentUser != null;
}
