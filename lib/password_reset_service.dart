import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends a password reset email to the provided email address
  Future<void> sendResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No account found for that email.');
      } else {
        throw Exception(e.message ?? 'Failed to send password reset email.');
      }
    }
  }
}
