import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/util/Properties.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import '../model/AnimeDetails.dart';

class JikanApiService{
  
  factory JikanApiService() {
    return _singleton;
  }
  static final JikanApiService _singleton = JikanApiService._internal();

  JikanApiService._internal();
  
  List<Anime> animeListInMemory = [];

  List<bool> isDayLoaded = [false, false, false, false, false, false, false];

  listarAnimesUsuario(usuarioMal) async{

    String url = Properties.URL_API_CONSULTA + "/user/"+usuarioMal+"/animelist/watching";    
    http.Response response = await http.get(Uri.parse(url));
    ApiResponse apiResponse;
    if (response.statusCode == 200) {
      var dadosJson = json.decode(response.body);
      List<Anime> lista = [];
      for (var item in dadosJson['anime']) {
        //print(item);
        Anime anime = Anime.fromJson(item);
        lista.add(anime);
      }
      
      apiResponse = ApiResponse<List<Anime>>(data: lista, isError: false);
      return apiResponse;
    }

  }

  Future<void> loadJsonDatafromFile() async {
      if(isDayLoaded.lastIndexWhere((element) => element == true) == -1){
        var jsonText = await rootBundle.loadString('assets/schedule.json');
        animeListInMemory =  _parseJsonAnimeData(jsonText);
        isDayLoaded = [true, true, true, true, true, true, true];
      }
      return;
  }

  Future<String> loadFromURL(String url, [http.Client clientMock]) async{
    http.Response response;
    if(clientMock != null){
      response = await clientMock.get(
        Uri.parse(url),
      );
    }else{
      response = await http.get(
        Uri.parse(url),
      );
    }
    if(response.statusCode == 200){
      return response.body;
    }else{
      throw Exception(response.body);
    }
  }

  ///Para carregamento dos dados da API de forma eficiente, esse método considera a diferença de fuso horário e faz a busca pela URL
  ///no dia corrente e também no dia adjacente
  Future<void> loadJsonDataByWeekday(int weekday, [http.Client clientMock]) async{
    List<Anime> animeData = [];
    if(!isDayLoaded[weekday]){
      String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000&filter="+Anime.diasSemanaLista[weekday];
      String loadedData = await loadFromURL(url, clientMock);
      animeData.addAll(_parseJsonAnimeData(loadedData));
      isDayLoaded[weekday] = true;
    }
    int timeZoneDiff = getTimezoneDiffToJapan();
    if(timeZoneDiff != 0){
      int weekdayAdj = timeZoneDiff < 0 ? (weekday + 1) % 7 : (weekday - 1) % 7;
      if(!isDayLoaded[weekdayAdj]){
        String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000&filter="+Anime.diasSemanaLista[weekdayAdj];
        isDayLoaded[weekdayAdj] = true;
        String loadedData = await loadFromURL(url, clientMock);
        animeData.addAll(_parseJsonAnimeData(loadedData));
      }
    }
    animeListInMemory.addAll(animeData);
    return;
    //return animeData;
  }

  List<Anime> _parseJsonAnimeData(String jsonBruto){
    var dadosJson = json.decode(jsonBruto);
    List<Anime> parsedAnimeList = [];
    for (var item in dadosJson["data"]) {
      if(item['broadcast']['time'] != null){
        Anime anime = Anime.fromJson(item);
        parsedAnimeList.add(anime);
      }
    }
    return parsedAnimeList;
  }
  
  ///Diferença de timezone da localização do fuso horário atual com o do Japão. Ex.: No Brasil é o offset é -3, então o timeZoneDiff será -3-9 = -12
  int getTimezoneDiffToJapan(){
    int timeZoneOffsetJapan = 9;
    final dateNow = DateTime.now().toLocal();
    return  dateNow.timeZoneOffset.inHours - timeZoneOffsetJapan;
  }

  ///O primeiro resultado é a hora convertida na timezone 
  String getCorrectedBroadcastTime(String broadcastTimeApi, [int timezoneDiff]){
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

    ///O primeiro resultado é a hora convertida na timezone 
  DateTime getCorrectedBroadcastEnd(String broadcastEndApi, String broadcastTimeApi){
    DateTime dateTime = null;
    if(broadcastEndApi != null && broadcastEndApi.isNotEmpty){
      dateTime = DateTime.parse(broadcastEndApi);
      int dayDiff = getDiffOfDaysBetweenSelectedAndBroadcastDay(broadcastTimeApi);
      dateTime = dateTime.add(Duration(days: dayDiff));
    }
    return dateTime;
  }

  ///Retorna a quantidade de dias que a diferença de timezone impacta no broadcastTime passado como parâmetro.
  ///Se o broadcastTime for 10:00 mas o timezoneDiff -12, espera-se que o timeDiff seja -1
  ///Da mesma forma, o broadcastTime for 20:00 mas o timezoneDiff -5, espera-se que o timeDiff seja 1
  int getDiffOfDaysBetweenSelectedAndBroadcastDay(String broadcastTime, [int timezoneDiff]){
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

  bool verifyIfIsAnimeInSelectedDay(int selectedDay, String broadcastDay, String broadcastTime){
    try{
      int dayDiff = getDiffOfDaysBetweenSelectedAndBroadcastDay(broadcastTime);
      String correctedBroadcastDay = Anime.diasSemanaListaCapitalized[(selectedDay - dayDiff) % 7];
      return correctedBroadcastDay == broadcastDay;
    }catch(e){
      return false;
    }
  }

  Future<List<Anime>> findAllByDay(selectedDay) async {
    //List<Anime> loadedAnimeData = await loadJsonData();
    List<Anime> dailyAnimeList = [];
    await loadJsonDatafromFile();
    await loadJsonDataByWeekday(selectedDay);
    animeListInMemory.forEach((element) {
      if(verifyIfIsAnimeInSelectedDay(selectedDay, element.broadcastDayApi, element.broadcastTimeApi)){
        Anime anime = element;
        anime.correctBroadcastTime = getCorrectedBroadcastTime(element.broadcastTimeApi);
        anime.correctBroadcastDay = Anime.diasSemanaListaCapitalized[selectedDay];
        anime.correctBroadcastEnd = getCorrectedBroadcastEnd(element.broadcastEndApi, element.broadcastTimeApi);
        dailyAnimeList.add(anime);
      }
    });
    dailyAnimeList.sort();
    return dailyAnimeList;
  }

  Future<Anime> loadAnimeDetails(Anime anime, [http.Client http]) async {
    //Anime anime = ;
    String url = Properties.URL_API_CONSULTA + "/anime/${anime.id}/full";
    String loadedData = await loadFromURL(url, http);
    var dadosJson = json.decode(loadedData);
    anime.animeDetails = AnimeDetails.fromJson(dadosJson);
    print("carregou dados");
    print(anime.animeDetails.genres.toString());
    return anime;
  }
}