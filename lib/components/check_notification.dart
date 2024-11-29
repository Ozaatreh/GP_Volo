import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:graduation_progect_v2/authentication/auth.dart';
import 'package:graduation_progect_v2/main.dart';
import 'package:graduation_progect_v2/pages/about_us_page.dart';

class NotificationPermissionScreen extends StatefulWidget {
  @override
  _NotificationPermissionScreenState createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  @override
  void initState() {
    super.initState();
    checkNotificationPermission();
  }

  Future<void> checkNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Request permission if not granted
      bool permissionGranted = await AwesomeNotifications()
          .requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Vibration,
        ],
      );

      if (!permissionGranted) {
        // If permission not granted, show dialog and block app access
        showPermissionDialog();
      } else {
        // If permission is granted, navigate to the main app
        navigateToApp();
      }
    } else {
      // If already allowed, proceed to the main app
      navigateToApp();
    }
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
              'Notification permission is required to use this app. Please enable it to proceed.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await checkNotificationPermission(); // Retry permission check
              },
              child: Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void navigateToApp() {
    Navigator.push( context,
      MaterialPageRoute(
        builder: ((context) => Authpage()),
          ), ); // Replace with your app route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loader while checking permissions
      ),
    );
  }
}
