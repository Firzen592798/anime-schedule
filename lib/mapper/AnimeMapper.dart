import '../core/Consts.dart';
import '../domain/AnimeLocal.dart';
import '../model/AnimeApi.dart';

class AnimeMapper{

  ///Diferença de timezone da localização do fuso horário atual com o do Japão. Ex.: No Brasil é o offset é -3, então o timeZoneDiff será -3-9 = -12
  static int getTimezoneDiffToJapan(){
    int timeZoneOffsetJapan = 9;
    final dateNow = DateTime.now().toLocal();
    return  dateNow.timeZoneOffset.inHours - timeZoneOffsetJapan;
  }

  ///Retorna a quantidade de dias que a diferença de timezone impacta no broadcastTime passado como parâmetro.
  ///Se o broadcastTime for 10:00 mas o timezoneDiff -12, espera-se que o timeDiff seja -1
  ///Da mesma forma, o broadcastTime for 20:00 mas o timezoneDiff -5, espera-se que o timeDiff seja 1
  static int getDiffOfDaysBetweenSelectedAndBroadcastDay(String broadcastTime, [int timezoneDiff]){
    if(timezoneDiff == null){
      timezoneDiff = getTimezoneDiffToJapan();
    }
    try{
      List<String> broadcastTimeSplit = broadcastTime.split(":");
      int broadcastHour = int.parse(broadcastTimeSplit[0]);
      int dayDiff = (broadcastHour + timezoneDiff) < 0 ? -1 : (broadcastHour + timezoneDiff) >= 24 ? 1 : 0;
      return dayDiff;
    }catch(e){
      return 0;
    }
  }

  static bool verifyIfIsAnimeInSelectedDay(int selectedDay, String broadcastDay, String broadcastTime){
    try{
      int dayDiff = getDiffOfDaysBetweenSelectedAndBroadcastDay(broadcastTime);
      String correctedBroadcastDay = Consts.diasSemanaListaCapitalized[(selectedDay - dayDiff) % 7];
      return correctedBroadcastDay == broadcastDay;
    }catch(e){
      return false;
    }
  }

  ///O primeiro resultado é a hora convertida na timezone 
  static DateTime getCorrectedBroadcastDate(String broadcastEndApi, String broadcastTimeApi){
    DateTime dateTime = null;
    if(broadcastEndApi != null && broadcastEndApi.isNotEmpty){
      dateTime = DateTime.parse(broadcastEndApi);
      int dayDiff = getDiffOfDaysBetweenSelectedAndBroadcastDay(broadcastTimeApi);
      dateTime = dateTime.add(Duration(days: dayDiff));
    }
    return dateTime;
  }

  ///O primeiro resultado é a hora convertida na timezone 
  static String getCorrectedBroadcastTime(String broadcastTimeApi, [int timezoneDiff]){
    try{
      if(timezoneDiff == null){
        timezoneDiff = getTimezoneDiffToJapan();
      }
      List<String> broadcastTimeApiSplit = broadcastTimeApi.split(":");
      int broadcastHour = int.parse(broadcastTimeApiSplit[0]);
      int correctedHour = (broadcastHour + timezoneDiff) % 24;
      String correctedHourStr = correctedHour.toString().padLeft(2, "0");
      return correctedHourStr+":"+broadcastTimeApiSplit[1];
    }catch(e){
      return broadcastTimeApi;
    }
  }

  static List<AnimeLocal> convertAnimeRemoteToAnimeLocal(List<AnimeApi> remoteAnimeList){
    List<AnimeLocal> list = [];
    remoteAnimeList.forEach((element) {
        AnimeLocal anime = AnimeLocal();
        anime.id = element.id;
        anime.titulo = element.titulo;
        anime.urlImagem = element.urlImagem;
        anime.episodios = element.episodios;
        anime.marcado = false;
        anime.correctBroadcastTime = getCorrectedBroadcastTime(element.broadcastTimeApi);
        int dayDiff = getDiffOfDaysBetweenSelectedAndBroadcastDay(element.broadcastTimeApi);
        int selectedDayIndex = Consts.diasSemanaListaCapitalized.indexOf(element.broadcastDayApi);
        anime.correctBroadcastDay = Consts.diasSemanaListaCapitalized[(selectedDayIndex + dayDiff) % 7];
        anime.correctBroadcastStart = getCorrectedBroadcastDate(element.broadcastStartApi, element.broadcastTimeApi);
        anime.correctBroadcastEnd = getCorrectedBroadcastDate(element.broadcastEndApi, element.broadcastTimeApi);
        list.add(anime);
    });
    return list;
  }
}