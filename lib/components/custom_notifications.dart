import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class CustomNotification extends StatefulWidget {
  const CustomNotification({super.key});

  @override
  State<CustomNotification> createState() => CustomNotificationState();
}

class CustomNotificationState extends State<CustomNotification> {
  
  void initializeNotifications() {
    AwesomeNotifications().initialize(
      null, // Use null for default icon
      [
        NotificationChannel(
          channelKey: 'event_reminders',
          channelName: 'Event Reminders',
          channelDescription: 'Notifications to remind users about upcoming events',
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );
  }

  void scheduleEventNotifications(DateTime eventDate) {
    // Schedule 1st notification (1 week before event)
    scheduleNotification(
      id: 1,
      eventDate: eventDate.subtract(Duration(days: 7)),
      title: 'Event Reminder',
      body: 'Your event is happening in 1 week. Get ready!',
    );

    // Schedule 2nd notification (3 days before event)
    scheduleNotification(
      id: 2,
      eventDate: eventDate.subtract(Duration(days: 3)),
      title: 'Event Reminder',
      body: 'Your event is happening in 3 days. Don’t miss it!',
    );

    // Schedule 3rd notification (1 day before event)
    scheduleNotification(
      id: 3,
      eventDate: eventDate.subtract(Duration(days: 1)),
      title: 'Event Reminder',
      body: 'Your event is happening tomorrow. Stay prepared!',
    );
  }

  void scheduleNotification({
    required int id,
    required DateTime eventDate,
    required String title,
    required String body,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'event_reminders',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: eventDate.year,
        month: eventDate.month,
        day: eventDate.day,
        hour: 23, // Notification time (9:00 AM)
        minute: 10,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeNotifications();

    // Request notification permissions if not already granted
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications(
            permissions: [
              NotificationPermission.Vibration,
              NotificationPermission.Sound,
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Example event date: December 1, 2024
          DateTime eventDate = DateTime(2024, 12, 1);
          scheduleEventNotifications(eventDate);
        },
        child: Text('Schedule Notifications'),
      ),
    );
  }
}
