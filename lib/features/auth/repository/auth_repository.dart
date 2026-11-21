import 'package:fintrack/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/core/errors/failures.dart';
import 'package:fintrack/features/auth/model/app_user.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  const AuthRepository({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;
  AppUser? get currentUser {
  final user = _authService.currentUser;
  return user == null ? null : _toAppUser(user);
}

Future<void> signOut() => _authService.signOut();

  static const String _genericError = 'Something went wrong. Please try again.';

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signInWithEmail(
        email: email.trim(),
        password: password,
      );
      if (user == null) throw const AuthFailure(_genericError);
      return _toAppUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageFor(e.code));
    }
  }

 Future<AppUser> register({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    final user = await _authService.registerWithEmail(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
    if (user == null) throw const AuthFailure(_genericError);

    final appUser = _toAppUser(user);

    await _authService.signOut();

    return appUser;
  } on FirebaseAuthException catch (e) {
    throw AuthFailure(_messageFor(e.code));
  }
}
  Future<AppUser?> signInWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) throw const AuthFailure(_genericError);
      return _toAppUser(user);
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException ${e.code}: ${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthFailure(_googleMessageFor(e.code));
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException ${e.code}: ${e.message}');
      if (_isCancellation(e.code)) return null; 
      throw AuthFailure(_messageFor(e.code));
    }
  }

  AppUser _toAppUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  static bool _isCancellation(String code) {
    return code == 'popup-closed-by-user' || code == 'cancelled-popup-request';
  }

  static String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password is too weak. Use at least 8 characters.';
      case 'operation-not-allowed':
        return 'Email sign-up is not enabled for this app.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'popup-blocked':
        return 'The sign-in popup was blocked. Allow popups for this site and try again.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for sign-in.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return _genericError;
    }
  }

  static String _googleMessageFor(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google sign-in is not set up correctly.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google Play Services is unavailable or out of date on this device.';
      case GoogleSignInExceptionCode.interrupted:
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in was interrupted. Please try again.';
      default:
        return _genericError;
    }
  }
}