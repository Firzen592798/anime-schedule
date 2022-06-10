import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/util/Properties.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ApiService{
  
  factory ApiService() {
    return _singleton;
  }
  static final ApiService _singleton = ApiService._internal();

  ApiService._internal();
  
  List<Anime> animeListInMemory;

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

  Future<String> loadJsonData() async {
      var jsonText = await rootBundle.loadString('assets/schedule.json');
      return jsonText;
  }

  Future<String> loadFromURL(String url) async{
    http.Response response = await http.get(
      Uri.parse(url),
    );
    if(response.statusCode == 200){
      return response.body;
    }else{
      throw Exception(response.body);
    }
  }
  
  int getTimezoneDiffToJapan(){
    int timeZoneOffsetJapan = 9;
    final dateNow = DateTime.now().toLocal();
    //Diferença de timezone da localização do fuso horário atual com o do Japão. Ex.: No Brasil é o offset é -3, então o timeZoneDiff será -3-9 = -12
    return  dateNow.timeZoneOffset.inHours - timeZoneOffsetJapan;
  }

  ///O primeiro resultado é a hora convertida na timezone 
  ///O segundo resultado indica se a hora retornada corresponde ao mesmo dia, dia anterior ou dia atual. Os únicos valores possíveis são -1, 0 e 1.
  String getCorrectedBroadcastTime(String broadcastTime, [int timezoneDiff]){
    try{
      if(timezoneDiff == null){
        timezoneDiff = getTimezoneDiffToJapan();
      }
      List<String> broadcastTimeSplit = broadcastTime.split(":");
      int broadcastHour = int.parse(broadcastTimeSplit[0]);
      int correctedHour = (broadcastHour + timezoneDiff) % 24;
      String correctedHourStr = correctedHour.toString().padLeft(2, "0");
      return correctedHourStr+":"+broadcastTimeSplit[1];
    }catch(e){
      return broadcastTime;
    }
    
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

  Future<void> loadJsonAnimeDataListInMemory() async {
    //String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000";
    //var jsonBruto = await loadFromURL(url);
    var jsonBruto = await loadJsonData();
    var dadosJson = json.decode(jsonBruto);
    animeListInMemory = [];
    for (var item in dadosJson["data"]) {
      if(item['broadcast']['time'] != null){
        Anime anime = Anime.fromJson(item);
        animeListInMemory.add(anime);
      }
    }
  }

  List<Anime> findAllByDay(selectedDay){
    List<Anime> dailyAnimeList = [];
    animeListInMemory.forEach((element) {
      if(verifyIfIsAnimeInSelectedDay(selectedDay, element.broadcastDayApi, element.broadcastTimeApi)){
        Anime anime = element;
        anime.correctBroadcastTime = getCorrectedBroadcastTime(element.broadcastTimeApi);
        anime.correctBroadcastDay = Anime.diasSemanaListaCapitalized[selectedDay];
        dailyAnimeList.add(anime);
      }
    });
    dailyAnimeList.sort((a, b) {
      return a.correctBroadcastTime.compareTo(b.correctBroadcastTime);
    },);
    return dailyAnimeList;
  }
}