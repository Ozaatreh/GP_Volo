import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_progect_v2/components/my_buttons.dart';
import 'package:graduation_progect_v2/components/my_textfield.dart';
import 'package:graduation_progect_v2/helper/err_message.dart';


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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailControler.text, password: passwordControler.text);
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e2) {
      displayMessageToUser(e2.code, context);
      
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

                const SizedBox(
                  height: 25,
                ),

                Text(
                  "V o l u n t u r s",
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
                    Text(
                      "ForgetPassword?",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
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