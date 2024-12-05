import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/components/my_buttons.dart';
import 'package:graduation_progect_v2/components/my_textfield.dart';
import 'package:graduation_progect_v2/helper/err_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.loginPageTap});

  final Function()? loginPageTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailControler = TextEditingController();
  final TextEditingController passwordControler = TextEditingController();
  bool isLoading = false;

  /// Fetch the user type from Firestore
  Future<String?> getUserType(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Users') // Ensure this matches your Firestore collection
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['userType'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching user type: $e');
      return null;
    }
  }

  void loginUser() async {
  if (emailControler.text.isEmpty || passwordControler.text.isEmpty) {
    displayMessageToUser("Fields cannot be empty", context);
    return;
  }

  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailControler.text)) {
    displayMessageToUser("Invalid email format", context);
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    // Authenticate the user
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailControler.text,
      password: passwordControler.text,
    );

    // Access the user
    final User? user = userCredential.user;
    if (user == null) throw FirebaseAuthException(code: "user-not-found");

    // Check if the email is verified
    if (!user.emailVerified) {
      // Show email verification prompt
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Email Not Verified'),
          content: const Text(
              'Please verify your email. Would you like to resend the verification email?'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await user.sendEmailVerification();
                  displayMessageToUser('Verification email sent.', context);
                } catch (e) {
                  displayMessageToUser('Error sending verification email.', context);
                }
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Resend Verification Email'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      return; // Stop login process
    }

    // Navigate based on user type
    if (mounted) {
      final userType = await getUserType(user.uid); // Fetch user type from Firestore
      switch (userType) {
        case 'Admin':
          Navigator.pushReplacementNamed(context, 'Admin_page');
          break;
        case 'Ngo':
          Navigator.pushReplacementNamed(context, 'Ngo_page');
          break;
        case 'User':
          Navigator.pushReplacementNamed(context, 'User_page');
          break;
        case 'Leader':
          Navigator.pushReplacementNamed(context, 'Leader_page');
          break;
        case 'University': // Handle university user type
          Navigator.pushReplacementNamed(context, 'University_page');
          break;
        default:
          Navigator.pushReplacementNamed(context, 'Home_page'); // Default page
      }
    }
  } on FirebaseAuthException catch (e) {
    displayMessageToUser(e.code, context);
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}


  @override
  void dispose() {
    emailControler.dispose();
    passwordControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 90),
                Text(
                  "V o l u n t u r s",
                  style: GoogleFonts.nanumMyeongjo(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 50),

                // Email textfield
                MyTextfield(
                  hintText: "Email",
                  obscuretext: false,
                  controller: emailControler,
                ),
                const SizedBox(height: 25),

                // Password textfield
                MyTextfield(
                  hintText: "Password",
                  obscuretext: true,
                  controller: passwordControler,
                ),
                const SizedBox(height: 10),

                // Forget password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'forgot_password'); // Adjust route as needed
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Login Button
                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(buttonText: "Login", onTap: loginUser),
                const SizedBox(height: 7),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.loginPageTap,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          " Register Here",
                          style: GoogleFonts.roboto(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}