import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/core/ApiResponse.dart';
import 'package:animeschedule/core/Properties.dart';
import 'package:animeschedule/service/IAnimeApiService.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import '../domain/AnimeDetails.dart';

class JikanApiService implements IAnimeAPiService{
  
  //http.Client _httpClient;
  Client _httpClient = Client();

  set httpClient(Client mock) => this._httpClient = mock;

  factory JikanApiService() {
    return _singleton;
  }
  static final JikanApiService _singleton = JikanApiService._internal();

  JikanApiService._internal();
  
  List<Anime> animeListInMemory = [];

  List<bool> _isDayLoaded = [false, false, false, false, false, false, false];

  Future<ApiResponse<List<Anime>>> listarAnimesUsuario(usuarioMal) async{

    String url = Properties.URL_API_CONSULTA + "/user/"+usuarioMal+"/animelist/watching";    
    Response response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var dadosJson = json.decode(response.body);
      List<Anime> lista = [];
      for (var item in dadosJson['anime']) {
        //print(item);
        Anime anime = Anime.fromJson(item);
        lista.add(anime);
      }
      return ApiResponse<List<Anime>>(data: lista, isError: false);
    }else{
      return ApiResponse<List<Anime>>(data: null, isError: true, errorMessage: "Erro ao recuperar os animes");
    }
  }

  Future<List<Anime>> fetchJsonDatafromFile() async {
      var jsonText = await rootBundle.loadString('assets/schedule.json');
      List<Anime> animes =  _parseJsonAnimeData(jsonText);
      return animes;
  }

  Future<void> _loadJsonDatafromFile() async {
      if(_isDayLoaded.every((element) => element == false)){ 
        animeListInMemory =  await fetchJsonDatafromFile();
        _isDayLoaded = [true, true, true, true, true, true, true];
      }
      return;
  }

  Future<String> loadFromURL(String url) async{
    Response response;

    response = await _httpClient.get(
      Uri.parse(url),
    );
    
    if(response.statusCode == 200){
      return response.body;
    }else{
      throw Exception(response.body);
    }
  }

  ///Para carregamento dos dados da API de forma eficiente, esse método considera a diferença de fuso horário e faz a busca pela URL
  ///no dia corrente e também no dia adjacente
  Future<void> loadJsonDataByWeekday(int weekday) async{
    List<Anime> animeData = [];
    if(!_isDayLoaded[weekday]){
      String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000&filter="+Anime.diasSemanaLista[weekday];
      String loadedData = await loadFromURL(url);
      animeData.addAll(_parseJsonAnimeData(loadedData));
      _isDayLoaded[weekday] = true;
    }
    int timeZoneDiff = getTimezoneDiffToJapan();
    if(timeZoneDiff != 0){
      int weekdayAdj = timeZoneDiff < 0 ? (weekday + 1) % 7 : (weekday - 1) % 7;
      if(!_isDayLoaded[weekdayAdj]){
        String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000&filter="+Anime.diasSemanaLista[weekdayAdj];
        _isDayLoaded[weekdayAdj] = true;
        String loadedData = await loadFromURL(url);
        animeData.addAll(_parseJsonAnimeData(loadedData));
      }
    }
    animeListInMemory.addAll(animeData);
    return;
  }

    ///Para carregamento dos dados da API de forma eficiente, esse método considera a diferença de fuso horário e faz a busca pela URL
  ///no dia corrente e também no dia adjacente
  Future<List<Anime>> fetchJsonDataScheduledAnimesOfWeek() async{
    List<Anime> animeData = [];
    String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000";
    String loadedData = await loadFromURL(url);
    animeData.addAll(_parseJsonAnimeData(loadedData));
    return animeData;
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
    await _loadJsonDatafromFile();
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

  Future<AnimeDetails> loadAnimeDetails(int id) async {
    //Anime anime = ;
    String url = Properties.URL_API_CONSULTA + "/anime/${id}/full";
    String loadedData = await loadFromURL(url);
    var dadosJson = json.decode(loadedData);
    AnimeDetails details = AnimeDetails.fromJson(dadosJson);
    return  details;
  }
}