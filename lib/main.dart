import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animeschedule/model/LocalNotification.dart';
import 'package:animeschedule/view/LoginView.dart';
import 'package:animeschedule/view/MeusAnimesView.dart';
import 'package:animeschedule/view/PreferenciasView.dart';
import 'package:flutter/material.dart';

import 'service/NotificationService.dart';

void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initPlugin();
  final int helloAlarmID = 0;
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
  LocalNotification lf = LocalNotification({"id": 1, "title": "Title", "body": "Body"});
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, () => { NotificationService().showNotification(lf)});
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MeusAnimesView(),
            routes: {
        //'/test': (_) => SearchTest(),
        //'/login': (_) => LoginView(),
        '/meusanimes': (_) => MeusAnimesView(),
        '/preferencias': (_) => PreferenciasView(),
      },
    );
  }
}
