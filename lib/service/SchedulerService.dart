import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:animeschedule/model/LocalNotification.dart';
import 'package:animeschedule/service/JikanApiService.dart';
import 'package:animeschedule/service/LocalStorageService.dart';
import 'package:animeschedule/service/NotificationService.dart';
import '../model/Anime.dart';

class SchedulerService{

  final fixedTimeScheduledId = 777;

  final dailyUpdateScheduledId = 999;

  LocalStorageService localService = LocalStorageService();

  JikanApiService jikanApiService = JikanApiService();

  NotificationService notificationService = NotificationService();

  static final SchedulerService _singleton = SchedulerService._internal();
  
  SchedulerService._internal();

  factory SchedulerService() {
    return _singleton;
  }

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
  Future<int> doRemoveMarksOfFinishedAnimes([DateTime dateNow]) async{
    if(dateNow == null){
      dateNow = DateTime.now();
    }
    int qtdRemovidos = 0;
    int weekday = DateTime.now().weekday - 1;
    List<Anime> animesFromLocalStorage = await localService.getMarkedAnimesByDay(weekday);
    if(animesFromLocalStorage.isNotEmpty){
      List<Anime> animesFromAPI = await jikanApiService.findAllByDay(weekday);
      animesFromLocalStorage.forEach((localAnime) {
        Anime anime = animesFromAPI.firstWhere((element) => localAnime.id == element.id);
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

  Future<DateTime> scheduleFixedTimeOfDay(String timeOfDay, [DateTime dateNow]) async {
    if(dateNow == null){
      dateNow = DateTime.now();
    }
    await AndroidAlarmManager.initialize();
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


    AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      fixedTimeScheduledId, 
      rearrangeNotifications,
      startAt: startDate, 
      allowWhileIdle: true,
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