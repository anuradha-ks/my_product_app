import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  // Listen for authentication changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user
  Future<User?> register(String email, String password) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // Sign in an existing user
  Future<User?> signIn(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update the user's password
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    User? user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw Exception('No user is currently signed in.');
    }

    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}