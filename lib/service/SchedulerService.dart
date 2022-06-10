import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animeschedule/model/LocalNotification.dart';
import 'package:animeschedule/service/LocalStorageService.dart';
import 'package:animeschedule/service/NotificationService.dart';

NotificationService notificationService = NotificationService();

LocalStorageService localService = LocalStorageService();

const fixedTimeScheduledId = 777;

void rearrangeNotifications() {
  print("Iniciando notificação");
  int weekday = DateTime.now().weekday - 1;
  print(weekday);
  localService.getMarkedAnimesByDay(weekday).then(((animeList) {
    notificationService.showNotification(LocalNotification.from(animeList));
  }));
}

class SchedulerService{

  static final SchedulerService _singleton = SchedulerService._internal();
  
  SchedulerService._internal();

  factory SchedulerService() {
    
    return _singleton;
  }

  scheduleFixedTimeOfDay(String timeOfDay) async {
    await AndroidAlarmManager.initialize();
    AndroidAlarmManager.cancel(fixedTimeScheduledId);
    int scheduledHour = int.tryParse(timeOfDay.split(":")[0]);
    int scheduledMinutes = int.tryParse(timeOfDay.split(":")[1]);
    DateTime now = DateTime.now();

    DateTime startDate = DateTime(now.year, now.month, now.day, scheduledHour, scheduledMinutes);
    //Verifica se o horário agendado do dia atual já passou, caso positivo joga a data de início para o dia seguinte
    print(now.hour.toString() +":"+ now.minute.toString() +":"+ scheduledHour.toString() +":"+ scheduledMinutes.toString());
    if((now.hour * 100 + now.minute) >= (scheduledHour * 100 + scheduledMinutes)){ 
      print("addDay");
      startDate = startDate.add(Duration(days: 1));
    }
    AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      fixedTimeScheduledId, 
      rearrangeNotifications,
      startAt: DateTime.now().add(Duration(seconds: 10)), 
      //startAt: startDate, 
      allowWhileIdle: true,
   );
   print("Agendado para "+startDate.toString());
  }

  cancelAll() async {
    await AndroidAlarmManager.initialize();
    AndroidAlarmManager.cancel(fixedTimeScheduledId);;
  }
}