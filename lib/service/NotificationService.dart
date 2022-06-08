import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:animeschedule/model/LocalNotification.dart';

class NotificationService{
  static final NotificationService _singleton = NotificationService._internal();
  
  NotificationService._internal();

  factory NotificationService() {
    return _singleton;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initPlugin() async {
    //FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    _setupTimezone();
  }

  Future<void> _setupTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  AndroidNotificationDetails _setupAndroidDetails() {
    return AndroidNotificationDetails('anime_notifications', 'Notificações de anime',
      channelDescription: 'Notificações sobre lançamento de episódios de anime',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
      fullScreenIntent: true);
  }

  void selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
}

  Future<void> showNotification(LocalNotification notification) async {
    AndroidNotificationDetails androidDetails =  _setupAndroidDetails();
    
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails);
    print("Notificação preparada");
    await flutterLocalNotificationsPlugin.show(
        notification.id, notification.title, notification.body, platformChannelSpecifics, 
        payload: notification.body).catchError((error) => print("erro de notificação: " + error.toString()));
  }

  showNotificationScheduled(LocalNotification notification, Duration duration) {
    AndroidNotificationDetails androidDetails = _setupAndroidDetails();

    final date = DateTime.now().add(duration);
    flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      
      tz.TZDateTime.from(date, tz.local),
      NotificationDetails(
        android: androidDetails,
      ),
      
      payload: notification.payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }


  void cancelNotification(){
    flutterLocalNotificationsPlugin.cancelAll();
  }

  void cancelNotificationById(int id){
    flutterLocalNotificationsPlugin.cancel(id);
  }
}