import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null, // Use null for default icon
    [
      NotificationChannel(
        channelKey: 'basic_channel'.tr(),
        channelName: 'Basic Notifications'.tr(),
        channelDescription: 'Notification channel for basic tests'.tr(),
        defaultColor: Colors.teal,
        ledColor: Colors.white,
      ),
    ],
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Notifications Test'.tr(),
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: NotificationTestPage(),
    );
  }
}

class NotificationTestPage extends StatefulWidget {
  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );
    super.initState();
    // scheduleEventNotificationsForTesting();
  }

  void _showTestNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1, // Unique ID for the notification
        channelKey: 'basic_channel'.tr(),
        title: 'Test Notification'.tr(),
        body: 'This is a test notification using Awesome Notifications!'.tr(),
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test'.tr()),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showTestNotification,
          child: Text('Show Notification'.tr()),
        ),
      ),
    );
  }
}
