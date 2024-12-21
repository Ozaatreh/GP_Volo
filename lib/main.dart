import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/authentication/auth.dart';
import 'package:graduation_progect_v2/components/check_notification.dart';
import 'package:graduation_progect_v2/components/custom_notifications.dart';
import 'package:graduation_progect_v2/components/nav_bar_leader.dart';
import 'package:graduation_progect_v2/components/nav_bar_ngo.dart';
import 'package:graduation_progect_v2/components/nav_bar_university.dart';
import 'package:graduation_progect_v2/components/nav_bar_users.dart';
import 'package:graduation_progect_v2/database/firebase_options.dart';
import 'package:graduation_progect_v2/helper/rating.dart';
import 'package:graduation_progect_v2/navigations/login_regis.dart';
import 'package:graduation_progect_v2/pages/about_us_page.dart';
import 'package:graduation_progect_v2/pages/achievement_page.dart';
import 'package:graduation_progect_v2/pages/admin/nav_bar_admin.dart';
import 'package:graduation_progect_v2/pages/auth_pages/forget_password.dart';
import 'package:graduation_progect_v2/pages/history_page.dart';
import 'package:graduation_progect_v2/pages/profile_pages/profile_page.dart';
import 'package:graduation_progect_v2/pages/rewards_creation.dart';
import 'package:graduation_progect_v2/pages/setting_page.dart';
import 'package:graduation_progect_v2/pages/users_log_page.dart';
import 'package:graduation_progect_v2/pages/wall_page.dart';
import 'package:graduation_progect_v2/theme/light_mode.dart';
import 'navigations/ngo_users.dart';
import 'theme/dark_mode.dart';


void main() async{
  AwesomeNotifications().initialize(
  null, // Use null for default app icon
  [
    NotificationChannel(
      channelKey: 'event_reminders',
      channelName: 'Event Reminders',
      channelDescription: 'Notifications to remind users about events',
      importance: NotificationImportance.High,
      channelShowBadge: true,
    ),
  ],
  debug: true, // Enable debug mode to check for issues in logs
);
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
      home:  SafeArea(child: NotificationPermissionScreen()
      ),
      theme: lightMode,
      darkTheme: darkMode,
      // Toggel pages
      routes: { 
        'login_register_page' : (context) => const LogRegAuthentication(),
        'Users_Toggle_page' : (context) =>  AllUsersToggle(),
        'Home_page' : (context) =>  WallPage(),
        'Admin_page': (context) =>  AdminNavigation(),
        'Ngo_page' : (context) =>  NGONavigation(),
        'User_page' : (context) =>  VolunteerNavigation(),
        'Leader_page' : (context) =>  LeaderNavigation(),
        'University_page' : (context) =>  UniversityNavigation(),
        'profile_page' : (context) =>  ProfilePage(),
        'users_log_page' : (context) => const UsersLogPage(),
        'about_us_page' : (context) => RatingPage(),
        'setting_page' : (context) =>  SettingsPage(),
        'Contact_us_page' :(context) =>  ContactUsPage(),
        '/history': (context) => const HistoryPage(),
        'forgot_password' :(context) =>  ForgotPasswordPage(),
        'AchievementPage' :(context) =>  AchievementPage(),
        'reward_creation': (context) => const RewardCreationPage(),
      },
     
    );
  }
}