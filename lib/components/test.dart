import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null, // Use null for default icon
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Notification channel for basic tests',
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
      title: 'Awesome Notifications Test',
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
        channelKey: 'basic_channel',
        title: 'Test Notification',
        body: 'This is a test notification using Awesome Notifications!',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showTestNotification,
          child: Text('Show Notification'),
        ),
      ),
    );
  }
}
