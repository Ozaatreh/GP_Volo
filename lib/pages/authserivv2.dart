import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // Register a new user
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      // Send verification email
      await userCredential.user?.sendEmailVerification();


      return userCredential.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }


  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    user = _auth.currentUser; // Refresh user info
    return user?.emailVerified ?? false;
  }
}



