import 'dart:convert';

import 'package:animeschedule/model/ConfigPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Anime.dart';

/// Service para gerenciar o armazenamento dos dados em local storage 
class LocalStorageService{
  static final LocalStorageService _singleton = LocalStorageService._internal();

  LocalStorageService._internal();

  factory LocalStorageService() {
    return _singleton;
  }

  Future<ConfigPrefs> getConfigPrefs(){
    return SharedPreferences.getInstance().then((prefs) {
      print(prefs.getInt("opcaoNotificacao") ?? 1);
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

  Future<void>adicionarMarcacaoAnime(Anime anime) async{
    await SharedPreferences.getInstance().then((prefs) {
      List<String> animelist = prefs.getStringList("animeList") ?? [];
      animelist.add(jsonEncode(anime.toJson()));
      print(animelist.toString());
      prefs.setStringList("animeList", animelist);
      print(prefs.getStringList("animeList").toString());
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

  Future<List<Anime>> getMarkedAnimes() async {
    List<Anime> animeList = [];
    await SharedPreferences.getInstance().then((prefs) {
      if(prefs.containsKey("animeList")){
        List<String> animes = prefs.getStringList("animeList");
        animeList = animes.map((e) => Anime.fromJsonLocal(jsonDecode(e))).toList();
      }
    });
    return animeList;
  }

  Future<List<Anime>> getMarkedAnimesByDay(int day) async {
    List<Anime> animeList = await getMarkedAnimes();
    List<Anime> dailyAnimeList = animeList.where((element) => (element.correctBroadcastDay == Anime.diasSemanaListaCapitalized[day])).toList();
    dailyAnimeList.sort();
    return dailyAnimeList;
  }
}