import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animeschedule/themes/AppTheme.dart';
import 'package:animeschedule/view/LoginView.dart';
import 'package:animeschedule/view/MeusAnimesView.dart';
import 'package:animeschedule/view/PreferenciasView.dart';
import 'package:flutter/material.dart';

import 'service-impl/NotificationService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await NotificationService().initPlugin();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme().themedata,
      debugShowCheckedModeBanner: false,
      home: MeusAnimesView(),
            routes: {
        //'/test': (_) => SearchTest(),
        '/login': (_) => LoginView(),
        '/meusanimes': (_) => MeusAnimesView(),
        '/preferencias': (_) => PreferenciasView(),
      },
    );
  }
}
