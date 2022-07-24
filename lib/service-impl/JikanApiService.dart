import 'package:animeschedule/model/AnimeApi.dart';
import 'package:animeschedule/core/Properties.dart';
import 'package:animeschedule/service/IAnimeApiService.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import '../core/Consts.dart';
import '../domain/AnimeDetails.dart';
import '../domain/AnimeLocal.dart';
import '../mapper/AnimeMapper.dart';

class JikanApiService implements IAnimeAPiService{
  
  //http.Client _httpClient;
  Client _httpClient = Client();

  set httpClient(Client mock) => this._httpClient = mock;

  factory JikanApiService() {
    return _singleton;
  }
  static final JikanApiService _singleton = JikanApiService._internal();

  JikanApiService._internal();
  
  List<AnimeLocal> animeListInMemory = [];

  List<bool> _isDayLoaded = [false, false, false, false, false, false, false];

  Future<List<AnimeLocal>> fetchJsonDatafromFile() async {
      var jsonText = await rootBundle.loadString('assets/schedule.json');
      List<AnimeApi> animes =  _parseJsonAnimeData(jsonText);
      List<AnimeLocal> animeLocal = AnimeMapper.convertAnimeRemoteToAnimeLocal(animes);
      return animeLocal;
  }

  Future<List<AnimeLocal>> _loadJsonDatafromFile() async {
      if(_isDayLoaded.every((element) => element == false)){ 
        await fetchJsonDatafromFile().then((animeRemoteList) {
          animeListInMemory = animeRemoteList;
          _isDayLoaded = [true, true, true, true, true, true, true];
        });
      }
      return animeListInMemory;
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
  Future<List<AnimeLocal>> loadJsonDataByWeekday(int weekday) async{
    List<AnimeLocal> animeData = [];
    if(!_isDayLoaded[weekday]){
      String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000&filter="+Consts.diasSemanaLista[weekday];
      String loadedData = await loadFromURL(url);
      animeData.addAll(AnimeMapper.convertAnimeRemoteToAnimeLocal(_parseJsonAnimeData(loadedData)));
      _isDayLoaded[weekday] = true;
    }
    int timeZoneDiff = AnimeMapper.getTimezoneDiffToJapan();
    if(timeZoneDiff != 0){
      int weekdayAdj = timeZoneDiff < 0 ? (weekday + 1) % 7 : (weekday - 1) % 7;
      if(!_isDayLoaded[weekdayAdj]){
        String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000&filter="+Consts.diasSemanaLista[weekdayAdj];
        _isDayLoaded[weekdayAdj] = true;
        String loadedData = await loadFromURL(url);
        animeData.addAll(AnimeMapper.convertAnimeRemoteToAnimeLocal(_parseJsonAnimeData(loadedData)));
      }
    }
    animeListInMemory.addAll(animeData);
    return animeListInMemory;
  }

    ///Para carregamento dos dados da API de forma eficiente, esse método considera a diferença de fuso horário e faz a busca pela URL
  ///no dia corrente e também no dia adjacente
  Future<List<AnimeLocal>> fetchJsonDataScheduledAnimesOfWeek() async{
    List<AnimeApi> animeData = [];
    String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000";
    String loadedData = await loadFromURL(url);
    animeData.addAll(_parseJsonAnimeData(loadedData));
    return AnimeMapper.convertAnimeRemoteToAnimeLocal(animeData);
  }

  List<AnimeApi> _parseJsonAnimeData(String jsonBruto){
    var dadosJson = json.decode(jsonBruto);
    List<AnimeApi> parsedAnimeList = [];
    for (var item in dadosJson["data"]) {
      if(item['broadcast']['time'] != null){
        AnimeApi anime = AnimeApi.fromJson(item);
        parsedAnimeList.add(anime);
      }
    }
    return parsedAnimeList;
  }

  Future<List<AnimeLocal>> findAllByDay(selectedDay) async {
    List<AnimeLocal> dailyAnimeList = [];
    //await _loadJsonDatafromFile();
    await loadJsonDataByWeekday(selectedDay);
    dailyAnimeList = animeListInMemory.where((element) => element.correctBroadcastDay == Consts.diasSemanaListaCapitalized[selectedDay]).toList();
    dailyAnimeList.sort();
    return dailyAnimeList;
  }

  Future<AnimeDetails> loadAnimeDetails(int id) async {
    String url = Properties.URL_API_CONSULTA + "/anime/${id}/full";
    String loadedData = await loadFromURL(url);
    var dadosJson = json.decode(loadedData);
    AnimeDetails details = AnimeDetails.fromJson(dadosJson);
    print(details);
    return  details;
  }
  
  @override
  Future<List<AnimeLocal>> findAll() async {
    String url = Properties.URL_API_CONSULTA + "/schedules?limit=4000";
    String loadedData = await loadFromURL(url);
    animeListInMemory = AnimeMapper.convertAnimeRemoteToAnimeLocal(_parseJsonAnimeData(loadedData));
     _isDayLoaded = [true, true, true, true, true, true, true];
    return animeListInMemory;
  }
}