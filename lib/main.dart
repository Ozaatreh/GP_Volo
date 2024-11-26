import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/authentication/auth.dart';
import 'package:graduation_progect_v2/components/nav_par_leader.dart';
import 'package:graduation_progect_v2/components/nav_par_ngo.dart';
import 'package:graduation_progect_v2/components/nav_par_users.dart';
import 'package:graduation_progect_v2/firebase_options.dart';
import 'package:graduation_progect_v2/helper/rating.dart';
import 'package:graduation_progect_v2/navigations/login_regis.dart';
import 'package:graduation_progect_v2/pages/about_us_page.dart';
import 'package:graduation_progect_v2/pages/profile_pages/profile_page.dart';
import 'package:graduation_progect_v2/pages/setting_page.dart';
import 'package:graduation_progect_v2/pages/users_log_page.dart';
import 'package:graduation_progect_v2/pages/wall_page.dart';
import 'package:graduation_progect_v2/theme/light_mode.dart';

import 'navigations/ngo_users.dart';
import 'theme/dark_mode.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // androidProvider: AndroidProvider.
  //   webRecaptchaSiteKey: 'your-site-key', //// For web, use your reCAPTCHA site key
  );
  // Initialize Firebase Messaging and request notification permissions
  // await FirebaseMessaging.instance.requestPermission();

  // Get the token for Firebase Cloud Messaging (FCM)
  // String? token = await FirebaseMessaging.instance.getToken();
  // print("FCM Token: $token"); // Log token for testing

  // CustomNotificationState().initializeNotifications();
  runApp(const MainPage());
}


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false ,
      home: const SafeArea(child: Authpage()
      ),
      theme: lightMode,
      darkTheme: darkMode,
      // Toggel pages
      routes: { 
        'login_register_page' : (context) => const LogRegAuthentication(),
        'User_Ngo_page' : (context) =>  NgoUsersToggle(),
        'Home_page' : (context) =>  WallPage(),
        'Ngo_page' : (context) =>  NGONavigation(),
        'User_page' : (context) =>  UserNavigation(),
        'Leader_page' : (context) =>  LeaderNavigation(),
        'profile_page' : (context) =>  ProfilePage(),
        'users_log_page' : (context) => const UsersLogPage(),
        'about_us_page' : (context) => PostSelectionPage(),
        'setting_page' : (context) =>  SettingsPage(),
        'Contact_us_page' :(context) =>  ContactUsPage(),
        
      },
     
    );
  }
}