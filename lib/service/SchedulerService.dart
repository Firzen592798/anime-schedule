import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animeschedule/model/LocalNotification.dart';
import 'package:animeschedule/service/LocalStorageService.dart';
import 'package:animeschedule/service/NotificationService.dart';

NotificationService notificationService = NotificationService();

LocalStorageService localService = LocalStorageService();

void rearrangeNotifications() {
  print("Iniciando notificação");
  int weekday = DateTime.now().weekday - 1;
  localService.getMarkedAnimes().then(((animeList) {
    notificationService.showNotification(LocalNotification.from(weekday, animeList));
  }));
}

class SchedulerService{
  Future<void> schedule() async {
    print("Schedule");
    await AndroidAlarmManager.initialize();
    final int isolateId = Isolate.current.hashCode;
    AndroidAlarmManager.periodic(const Duration(minutes: 1), isolateId, rearrangeNotifications);
    //AndroidAlarmManager.periodic(const Duration(days: 7), 0, printHello);
  }

  periodic(){
    final int isolateId = Isolate.current.hashCode;
    print("Hashcode "+isolateId.toString());
    AndroidAlarmManager.periodic(
      const Duration(minutes: 1), //Do the same every 24 hours
      isolateId, //Different ID for each alarm
      rearrangeNotifications,
      wakeup: true, //the device will be woken up when the alarm fires
      startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 5, 0), //Start whit the specific time 5:00 am
      rescheduleOnReboot: true, //Work after reboot
   );
  }
}