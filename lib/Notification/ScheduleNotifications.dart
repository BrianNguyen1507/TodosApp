import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todo/Notification/GetDateTime.dart';
import 'dart:async';

class NotificationController {
  static Future<void> initializeAndScheduleNotifications() async {
    bool isAllowToNoti = await AwesomeNotifications().isNotificationAllowed();
    if (isAllowToNoti) {
      scheduleAndCreateNotifications();
    }
  }
}

void scheduleAndCreateNotifications() async {
  GetNotificationDateTime notificationDateTime = GetNotificationDateTime();
  List<Map<String, dynamic>> taskDateTimeList =
      await notificationDateTime.getTaskDateTimeList();
  createScheduledNotifications(taskDateTimeList);
}

Future<void> createScheduledNotifications(
    List<Map<String, dynamic>> scheduledList) async {
  for (var scheduledItem in scheduledList) {
    String name = scheduledItem['name'];
    int id = scheduledItem['id'];
    DateTime scheduledDateTime = scheduledItem['dateTime'];
    //UTC+7 convert (Asia/Ho_Chi_minh timezone)
    scheduledDateTime = scheduledDateTime.toUtc().add(
          const Duration(hours: 7),
        );
    String formattedDateTime =
        scheduledDateTime.toIso8601String().replaceAll('Z', '');

    DateTime dateTime = DateTime.parse(formattedDateTime);

    await triggerNotification(dateTime, id, name);
  }
}

Future<void> triggerNotification(
    DateTime scheduledDateTime, int id, String name) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: 'alerts',
      title: 'To-do reminders',
      body: '$name is waiting for you to complete. Get it done!',
    ),
    schedule: NotificationCalendar(
      year: scheduledDateTime.year,
      month: scheduledDateTime.month,
      day: scheduledDateTime.day,
      hour: scheduledDateTime.hour,
      minute: scheduledDateTime.minute,
      second: 0,
      millisecond: 0,
      timeZone: 'Asia/Ho_Chi_Minh',
      repeats: true,
    ),
  );
}
