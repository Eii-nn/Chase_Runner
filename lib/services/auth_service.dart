import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
    clientId:
        '529539616962-ltq50c056unk3s7vma995na1jd5f9616.apps.googleusercontent.com', // Web client ID from Google Cloud Console
  );
  final _storage = const FlutterSecureStorage();
  final _log = Logger('AuthService');

  // Get current user
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return result;
    } catch (e) {
      _log.warning('Email sign-up failed', e);
      throw _handleAuthException(e as FirebaseAuthException);
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
    } catch (e) {
      _log.warning('Google sign-in failed', e);
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
