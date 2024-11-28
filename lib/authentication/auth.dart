import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/navigations/login_regis.dart';
import 'package:graduation_progect_v2/navigations/ngo_users.dart';

class Authpage extends StatelessWidget {
  const Authpage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(), builder: (context, snapshot) {
        // if loged in
       if(snapshot.hasData) { 
        return  AllUsersToggle();
       
       }
       // if not loged in
       else {
        return const LogRegAuthentication();
       } 
      },),
    );
  }
}