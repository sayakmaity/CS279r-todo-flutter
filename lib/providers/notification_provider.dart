import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_todo_app/models/task.dart';
import 'package:flutter_todo_app/views/screens/notification_screen.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationProvider {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// It initializes the notification plugin.
  initializeNotification() async {
    // tz.initializeTimeZones();
    await _configureLocalTimezone();
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/appicon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }
/* 
  displayNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  } */

  /// It schedules a notification for the task.
  scheduledNotification(
      {required Task task, required int hour, required int minutes}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      // tz.TZDateTime.from(
      //   DateTime.now().add(
      //     Duration(
      //       seconds: 5,
      //     ),
      //   ),
      //   tz.local,
      // ),
      _convertTime(hour, minutes),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${task.title}|${task.note}|${task.startTime}',
    );
  }

  /// It takes in an hour and a minute, and returns an object that is the next time that
  /// hour and minute will occur
  tz.TZDateTime _convertTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, hour, minute); // Create new date object with hour and minute
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  /// > It sets the local timezone to the timezone of the device
  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  /// A function that is called when a notification is clicked and it takes the user to the notification screen.
  Future selectNotification(String? payload) async {
    final String title = payload!.split('|')[0];
    final String note = payload.split('|')[1];
    final String startTime = payload.split('|')[2];
    Get.to(() => NotificationScreen(
          title: title,
          note: note,
          startTime: startTime,
        ));
  }
}
