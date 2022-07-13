import 'dart:convert';

import 'package:animeschedule/domain/ConfigPrefs.dart';
import 'package:animeschedule/service/ILocalStorageService.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/Consts.dart';
import '../domain/AnimeLocal.dart';

/// Service para gerenciar o armazenamento dos dados em local storage 
class LocalStorageService implements ILocalStorageService{
  static final LocalStorageService _singleton = LocalStorageService._internal();

  LocalStorageService._internal();

  factory LocalStorageService() {
    return _singleton;
  }

  Future<ConfigPrefs> getConfigPrefs(){
    return SharedPreferences.getInstance().then((prefs) {
      ConfigPrefs config = ConfigPrefs(); 
      config.usuarioMAL =  prefs.getString("usuarioMAL") ?? "";
      config.opcaoNotificacao =  prefs.getInt("opcaoNotificacao") ?? 1;
      config.horarioNotificacao =  prefs.getString("horarioNotificacao") ?? null;
      config.tempoAposOEpisodioParaDispararNotificacao =  prefs.getString("tempoAposOEpisodioParaDispararNotificacao") ?? null;
      return config;
    });
  }

  salvarPrefs(ConfigPrefs configPrefs){
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('opcaoNotificacao', configPrefs.opcaoNotificacao);
      if(configPrefs.horarioNotificacao != null){
        prefs.setString('horarioNotificacao', configPrefs.horarioNotificacao);
      }
      if(configPrefs.tempoAposOEpisodioParaDispararNotificacao != null) {
        prefs.setString('tempoAposOEpisodioParaDispararNotificacao', configPrefs.tempoAposOEpisodioParaDispararNotificacao);   
      }       
    });
  }

  Future<void>adicionarMarcacaoAnime(AnimeLocal anime) async{
    await SharedPreferences.getInstance().then((prefs) {
      List<String> animelist = prefs.getStringList("animeList") ?? [];
      animelist.add(jsonEncode(anime.toJson()));
      prefs.setStringList("animeList", animelist);
    });
    return;
  }

  Future<void> removerMarcacaoAnime(int id) async{
    await SharedPreferences.getInstance().then((prefs) {
      List<String> animelist = prefs.getStringList("animeList") ?? [];
      animelist.removeWhere((element) => element.contains('"mal_id":$id'));
      prefs.setStringList("animeList", animelist);
    });
  }

  Future<void> removerMarcacaoAnimesFinalizados([DateTime dateTimeNow]) async{
    if(dateTimeNow == null){
      dateTimeNow = new DateTime.now();
    }
    List<AnimeLocal> animeList = [];
    await SharedPreferences.getInstance().then((prefs) {
      List<String> animelistStr = prefs.getStringList("animeList") ?? [];
      animelistStr.forEach((element) {
        animeList.add(AnimeLocal.fromJson(json.decode(element)));
      });
      int lengthBeforeRemoval = animeList.length;
      animeList.removeWhere((element) => element.correctBroadcastEnd?.isBefore(dateTimeNow));
      if(lengthBeforeRemoval > animeList.length){
        atualizarMarcacoes(animeList);
      }
    });
    return;
  }

  Future<List<AnimeLocal>> getMarkedAnimes() async {
    List<AnimeLocal> animeList = [];
    await SharedPreferences.getInstance().then((prefs) {
      if(prefs.containsKey("animeList")){
        List<String> animes = prefs.getStringList("animeList");
        animeList = animes.map((e) => AnimeLocal.fromJson(jsonDecode(e))).toList();
      }
    });
    return animeList;
  }

  Future<List<AnimeLocal>> getMarkedAnimesByDay(int day) async {
    List<AnimeLocal> animeList = await getMarkedAnimes();
    animeList = animeList.where((element) => (element.correctBroadcastDay == Consts.diasSemanaListaCapitalized[day])).toList();
    animeList.sort();
    return animeList;
  }
  
  @override
  Future<List<String>> atualizarMarcacoes (List<AnimeLocal> animeLista) async{
    List<String> animelistStr = []; 
    await SharedPreferences.getInstance().then((prefs) {
      animeLista.forEach((element) {
        animelistStr.add(jsonEncode(element.toJson()));
      });
      prefs.setStringList("animeList", animelistStr);
    });
    return animelistStr;
  }

  @override
  Future<String> saveToken (String token) async{
    Map<String, dynamic> tokenMap = jsonDecode(token);
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString("token", tokenMap["access_token"]);
      prefs.setString("refreshToken", tokenMap["refresh_token"]);
    });
    return tokenMap["access_token"];
  }

  Future<String> getToken() async {
    String token;
    await SharedPreferences.getInstance().then((prefs) {
      token = prefs.getString("token");
    });
    return token;
  }
}