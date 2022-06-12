import 'dart:html';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animeschedule/model/LocalNotification.dart';
import 'package:animeschedule/service/JikanApiService.dart';
import 'package:animeschedule/service/LocalStorageService.dart';
import 'package:animeschedule/service/NotificationService.dart';
import 'package:timezone/timezone.dart';
import '../model/Anime.dart';

NotificationService notificationService = NotificationService();

LocalStorageService localService = LocalStorageService();

const fixedTimeScheduledId = 777;

const dailyUpdateScheduledId = 999;

void rearrangeNotifications() {
  print("Iniciando notificação");
  int weekday = DateTime.now().weekday - 1;
  print(weekday);
  localService.getMarkedAnimesByDay(weekday).then(((animeList) {
    if(animeList.isNotEmpty){
      notificationService.showNotification(LocalNotification.from(animeList));
    }
  }));
}

///Fazer uma rotina de teste para esse carinha aqui
void doRemoveMarksOfFinishedAnimes() async{
  int weekday = DateTime.now().weekday - 1;
  List<Anime> animesFromLocalStorage = await localService.getMarkedAnimesByDay(weekday);
  if(animesFromLocalStorage.isNotEmpty){
    List<Anime> animesFromAPI = await JikanApiService().findAllByDay(weekday);
    animesFromLocalStorage.forEach((localAnime) {
      Anime anime = animesFromAPI.firstWhere((element) => localAnime.id == element.id);
      if(anime != null && anime.correctBroadcastEnd != null){
        if(anime.correctBroadcastEnd.isAfter(DateTime.now())){
          localService.removerMarcacaoAnime(anime.id);
        }
      }
    });
  }
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
    //DateTime startDate = now;
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
      startAt: startDate, 
      allowWhileIdle: true,
   );
   print("Agendado para "+startDate.toString());
  }

  ///Ver como inicializar esse carinha aqui e fazer a parte de gerência de memória
  scheduleRemoveMarksOfFinishedAnimes(){
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0);
    AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      dailyUpdateScheduledId, 
      doRemoveMarksOfFinishedAnimes,
      startAt: startDate, 
      allowWhileIdle: true,
   );
  }

  cancelAll() async {
    await AndroidAlarmManager.initialize();
    AndroidAlarmManager.cancel(fixedTimeScheduledId);;
  }
}