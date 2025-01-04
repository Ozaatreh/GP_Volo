import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_progect_v2/components/my_buttons.dart';
import 'package:graduation_progect_v2/components/my_textfield.dart';
import 'package:graduation_progect_v2/helper/err_message.dart';
import 'package:graduation_progect_v2/pages/ngo_page.dart';
import 'package:graduation_progect_v2/pages/users_log_page.dart';
import 'package:graduation_progect_v2/pages/leaders_page.dart';
import 'package:graduation_progect_v2/pages/university_page.dart';



// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.loginPageTap});

  final Function()? loginPageTap;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailControler = TextEditingController();

  final TextEditingController passwordControler = TextEditingController();

  void loginUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailControler.text,
        password: passwordControler.text,
      );

      final user = userCredential.user;

      if (user != null) {
        await user.reload(); // Ensure the latest verification status

        if (!user.emailVerified) {
          if (context.mounted) Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Email Verification'),
              content: const Text('Please verify your email before logging in.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return; // Stop login if email is not verified
        }

        // Get user type from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .get();

        if (userDoc.exists) {
          final userType = userDoc.data()?['userType'] as String?;

          if (userType != null) {
            // Navigate based on user type
            if (userType == 'Ngo') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  NgoPage()));
            } else if (userType == 'Volunteer') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UsersLogPage()));
            } else if (userType == 'Leader') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LeadersPage()));
            } else if (userType == 'University') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UniversityPage()));
            }
          } else {
            // Handle case where userType is not found in the document
            displayMessageToUser("User type not found", context);
          }
        } else {
          // Handle case where user document doesn't exist
          displayMessageToUser("User document not found", context);
        }

        // Dismiss progress indicator after successful navigation or error handling
        if (context.mounted) Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Dismiss progress indicator if login fails
      if (context.mounted) Navigator.pop(context);
      displayMessageToUser(e.code, context);
    } catch (e) {
      // Handle other potential errors
      if (context.mounted) Navigator.pop(context);
      displayMessageToUser("An unknown error occurred", context);
    }
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
                const SizedBox(
                  height: 90,
                ),

                // Icon(
                //   Icons.person,
                //   size: 90,
                //   color: Theme.of(context).colorScheme.inversePrimary,
                // ),
                Image(image: AssetImage("assets/volunteers_icon.png"),colorBlendMode:BlendMode.darken, height: 150, width:150),

                const SizedBox(
                  height: 17,
                ),

                Text(
                  "V o l o",
                  style: GoogleFonts.nanumMyeongjo(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),

                // Email textfield
                MyTextfield(
                    hintText: "Email",
                    obscuretext: false,
                    controller: emailControler),

                const SizedBox(
                  height: 25,
                ),

                // Password textfield
                MyTextfield(
                    hintText: "Password",
                    obscuretext: true,
                    controller: passwordControler),

                const SizedBox(
                  height: 10,
                ),

                // forget password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(

                      child:  Text("ForgetPassword?",
                      style:  TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ), ),
                      onPressed: () { 
                        Navigator.pushNamed(context, 'forgot_password');
                       },
                    ),
                  ],
                ),

                const SizedBox(
                  height: 25,
                ),

                MyButton(buttonText: "Login", onTap: loginUser),

                const SizedBox(
                  height: 7,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont have an account?",
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.loginPageTap,
                      child:  Text(
                        " Register Here",
                        style: GoogleFonts.roboto(fontSize: 14 ,fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}