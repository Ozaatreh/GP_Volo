import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
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
          channelKey: 'event_reminders'.tr(),
          channelName: 'Event Reminders'.tr(),
          channelDescription: 'Notifications to remind users about upcoming events'.tr(),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );
  }
  
  void scheduleEventNotificationsForTesting() {
  scheduleNotification(
    id: 1,
    eventDate: DateTime.now().add(Duration(seconds: 15)), // More buffer time
    title: 'Test Reminder 1'.tr(),
    body: 'This is your first test notification!'.tr(),
  );

  scheduleNotification(
    id: 2,
    eventDate: DateTime.now().add(Duration(seconds: 30)),
    title: 'Test Reminder 2'.tr(),
    body: 'This is your second test notification!'.tr(),
  );

  scheduleNotification(
    id: 3,
    eventDate: DateTime.now().add(Duration(seconds: 45)),
    title: 'Test Reminder 3'.tr(),
    body: 'This is your third test notification!'.tr(),
  );
}


  void scheduleEventNotifications(DateTime eventDate) {
    // Schedule 1st notification (1 week before event)
    scheduleNotification(
      id: 1,
      eventDate: eventDate.subtract(Duration(days: 7)),
      title: 'Event Reminder'.tr(),
      body: 'Your event is happening in 1 week. Get ready!'.tr(),
    );

    // Schedule 2nd notification (3 days before event)
    scheduleNotification(
      id: 2,
      eventDate: eventDate.subtract(Duration(days: 3)),
      title: 'Event Reminder'.tr(),
      body: 'Your event is happening in 3 days. Don’t miss it!'.tr(),
    );

    // Schedule 3rd notification (1 day before event)
    scheduleNotification(
      id: 3,
      eventDate: eventDate.subtract(Duration(days: 1)),
      title: 'Event Reminder'.tr(),
      body: 'Your event is happening tomorrow. Stay prepared!'.tr(),
    );
  }

  void scheduleNotification({
  required int id,
  required DateTime eventDate,
  required String title,
  required String body,
}) async {
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'event_reminders'.tr(),
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: eventDate),
    );
    print('Notification $id scheduled successfully for $eventDate'.tr());
  } catch (e) {
    print('Failed to schedule notification $id: $e'.tr());
  }
}



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


  void cancelAllNotifications() {
  AwesomeNotifications().cancelAll();
  print("All notifications canceled.".tr());
}

void checkPermissions() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    print("Notifications are not allowed. Requesting permission...".tr());
    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Vibration,
        NotificationPermission.Sound,
      ],
    );
  } else {
    print("Notifications are allowed.".tr());
  }
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
  onPressed: () {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'event_reminders'.tr(),
        title: 'Test Notification'.tr(),
        body: 'This is a test notification'.tr(),
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(
        date: DateTime.now().add(Duration(seconds: 5)),
      ),
    );
  },
  child: Text('Send Test Notification').tr(),
),

    );
  }
}
