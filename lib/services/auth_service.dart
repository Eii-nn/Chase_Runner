import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email'
    ],
    signInOption: SignInOption.standard,
  );
  final _storage = const FlutterSecureStorage();
  final _log = Logger('AuthService');

  // Get current user
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await sendEmailVerification();

      notifyListeners();
      return result;
    } catch (e) {
      _log.warning('Email sign-up failed', e);
      throw _handleAuthException(e as FirebaseAuthException);
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      _log.warning('Failed to send verification email', e);
      throw 'Failed to send verification email: ${e.toString()}';
    }
  }

  // Check if email is verified and refresh user
  Future<bool> checkEmailVerified() async {
    try {
      // Reload user data to get the latest verification status
      await _auth.currentUser?.reload();
      final isVerified = _auth.currentUser?.emailVerified ?? false;
      notifyListeners();
      return isVerified;
    } catch (e) {
      _log.warning('Failed to check email verification', e);
      return false;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      await _storage.write(key: 'uid', value: result.user?.uid);
      return result;
    } catch (e) {
      _log.warning('Email sign-in failed', e);
      throw _handleAuthException(e as FirebaseAuthException);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // For Android, use a direct Firebase Auth approach
        _log.info('Using direct Firebase Auth approach for Android');

        // Create Google Auth Provider
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // Try to sign in directly with Firebase
        final result = await _auth.signInWithProvider(googleProvider);

        notifyListeners();
        await _storage.write(key: 'uid', value: result.user?.uid);
        return result;
      } else {
        // Use regular Google Sign-In for other platforms
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          throw 'Google sign in aborted';
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the credential
        final result = await _auth.signInWithCredential(credential);
        notifyListeners();
        await _storage.write(key: 'uid', value: result.user?.uid);

        return result;
      }
    } catch (e) {
      _log.warning('Google sign-in failed', e);
      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }

  // Simple Google sign in (alternative implementation)
  Future<UserCredential> signInWithGoogleSimple() async {
    try {
      // The signInWithGoogle method in FirebaseAuth uses a different approach
      // that might bypass some of the People API restrictions
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // On Android/iOS, this will use the native Google Sign-In flow
      final result = await _auth.signInWithPopup(googleProvider);
      notifyListeners();
      await _storage.write(key: 'uid', value: result.user?.uid);
      return result;
    } catch (e) {
      _log.warning('Simple Google sign-in failed', e);
      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _storage.delete(key: 'uid');
      notifyListeners();
    } catch (e) {
      _log.warning('Sign-out failed', e);
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _log.warning('Password reset failed', e);
      throw _handleAuthException(e);
    }
  }

  // Helper method to handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
