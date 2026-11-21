import 'package:firebase_auth/firebase_auth.dart';
import 'package:fintrack/core/constants/google_config.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  User? get currentUser => _auth.currentUser;
  bool _googleInitialized = false;

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;

    try {
      await user.updateDisplayName(name);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      debugPrint('updateDisplayName failed: ${e.code}');
    }
    return _auth.currentUser;
  }
  Future<void> signOut() => _auth.signOut();

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final result = await _auth.signInWithPopup(GoogleAuthProvider());
      return result.user;
    }

    await _ensureGoogleInitialized();

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Google did not return an ID token.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize(serverClientId: kGoogleServerClientId);
    _googleInitialized = true;
  }
}