import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animeschedule/domain/LocalNotification.dart';
import 'package:animeschedule/domain/AnimeLocal.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:animeschedule/service-impl/LocalStorageService.dart';
import 'package:animeschedule/service-impl/NotificationService.dart';
import 'package:animeschedule/service/IAnimeApiService.dart';
import '../service/ILocalStorageService.dart';

class SchedulerService{

  final fixedTimeScheduledId = 777;

  final dailyUpdateScheduledId = 999;

  static ILocalStorageService localService = LocalStorageService();

  IAnimeAPiService jikanApiService = JikanApiService();

  static NotificationService notificationService = NotificationService();

  static final SchedulerService _singleton = SchedulerService._internal();
  
  SchedulerService._internal();

  factory SchedulerService() {
    return _singleton;
  }

  static void doRearrangeNotifications() {
    print("doRearrangeNotification");
    int weekday = DateTime.now().weekday - 1;
    print(weekday);
    localService.getMarkedAnimesByDay(weekday).then(((animeList) {
      print("animeList");
      print(animeList);
      if(animeList.isNotEmpty){
        print("notEmpty");
        notificationService.showNotification(LocalNotification.from(animeList));
      }
    }));
  }

  Future<int> doRemoveMarksOfFinishedAnimes([DateTime dateNow]) async{
    if(dateNow == null){
      dateNow = DateTime.now();
    }
    int qtdRemovidos = 0;
    int weekday = DateTime.now().weekday - 1;
    List<AnimeLocal> animesFromLocalStorage = await localService.getMarkedAnimesByDay(weekday);
    if(animesFromLocalStorage.isNotEmpty){
      List<AnimeLocal> animesFromAPI = await jikanApiService.findAllByDay(weekday);
      animesFromLocalStorage.forEach((localAnime) {
        AnimeLocal anime = animesFromAPI.firstWhere((element) => localAnime.id == element.id);
        if(anime != null && anime.correctBroadcastEnd != null){
          if(anime.correctBroadcastEnd.isBefore(dateNow)){
            localService.removerMarcacaoAnime(anime.id);
            qtdRemovidos++;
          }
        }
      });
    }
    return qtdRemovidos;
  }

  Future<int> doRemoveMarksOfAnimesWithEndDateAfterNow([DateTime dateNow]) async{
    if(dateNow == null){
      dateNow = DateTime.now();
    }
    int qtdRemovidos = 0;
    int weekday = DateTime.now().weekday - 1;
    List<AnimeLocal> animesFromLocalStorage = await localService.getMarkedAnimesByDay(weekday);
    if(animesFromLocalStorage.isNotEmpty){
      List<AnimeLocal> animesFromAPI = await jikanApiService.findAllByDay(weekday);
      animesFromLocalStorage.forEach((localAnime) {
        AnimeLocal anime = animesFromAPI.firstWhere((element) => localAnime.id == element.id);
        if(anime != null && anime.correctBroadcastEnd != null){
          if(anime.correctBroadcastEnd.isBefore(dateNow)){
            localService.removerMarcacaoAnime(anime.id);
            qtdRemovidos++;
          }
        }
      });
    }
    return qtdRemovidos;
  }

  //Pesquisa os animes remotos e verifica se eles estão com a data de broadcast end atualizzada para ser repassada aos registros locais.
  Future<List<AnimeLocal>> doUpdateEndBroadcastOfLocalData([DateTime dateNow]) async{
    List<AnimeLocal> localAnimeData = await localService.getMarkedAnimes();
    if(!localAnimeData.isEmpty && localAnimeData.any((element) => element.correctBroadcastEnd == null)){
      List<AnimeLocal> remoteAnimeData = await jikanApiService.fetchJsonDatafromFile();
      localAnimeData.forEach((animeLocal) {
        remoteAnimeData.forEach((animeRemote) {
          if(animeLocal.id == animeRemote.id){
            animeLocal.correctBroadcastEnd = animeRemote.correctBroadcastEnd;
            animeLocal.correctBroadcastStart = animeRemote.correctBroadcastStart;
            animeLocal.correctBroadcastTime = animeRemote.correctBroadcastTime;
            animeLocal.correctBroadcastDay = animeRemote.correctBroadcastDay;
            animeLocal.episodios = animeRemote.episodios;
            animeLocal.urlImagem = animeRemote.urlImagem;
          }
        });
      });
      localService.atualizarMarcacoes(localAnimeData);
    }
    return localAnimeData;
  }

  static void alarmTest() {
    print("naostatic");
  }

  void runAlarm() {
    AndroidAlarmManager.oneShot(
      Duration(seconds: 10),
      1,
      doRearrangeNotifications,
      wakeup: true,
    ).then((val) => print(val));
  }

  void runPeriodicTest(){
    AndroidAlarmManager.periodic(
      Duration(seconds: 60),
      1, 
      alarmTest,
      startAt: DateTime.now(), 
      wakeup: true,
   );
  }

  Future<DateTime> scheduleFixedTimeOfDay(String timeOfDay, [DateTime dateNow]) async {
    AndroidAlarmManager.cancel(0);
    AndroidAlarmManager.cancel(1);
    AndroidAlarmManager.cancel(2);
    runAlarm();
    if(dateNow == null){
      dateNow = DateTime.now();
    }
    print("Agendando para ${timeOfDay} para o dia ${dateNow.toIso8601String()}");
    //await AndroidAlarmManager.initialize();
    
    AndroidAlarmManager.cancel(fixedTimeScheduledId);
    int scheduledHour = int.tryParse(timeOfDay.split(":")[0]);
    int scheduledMinutes = int.tryParse(timeOfDay.split(":")[1]);
    //DateTime startDate = now;
    DateTime startDate = DateTime(dateNow.year, dateNow.month, dateNow.day, scheduledHour, scheduledMinutes);
    //Verifica se o horário agendado do dia atual já passou, caso positivo joga a data de início para o dia seguinte
    print(dateNow.hour.toString() +":"+ dateNow.minute.toString() +":"+ scheduledHour.toString() +":"+ scheduledMinutes.toString());
    if((dateNow.hour * 100 + dateNow.minute) >= (scheduledHour * 100 + scheduledMinutes)){ 
      print("addDay");
      startDate = startDate.add(Duration(days: 1));
    }

    print("Agendado para ${startDate.toIso8601String()}");
    AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      0, 
      doRearrangeNotifications,
      startAt: DateTime.now(), 
      allowWhileIdle: true,
      wakeup: true,
   );
   return startDate;
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