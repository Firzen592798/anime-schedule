import 'dart:convert';

import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/model/ConfigPrefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**Service para gerenciar o armazenamento dos dados em local storage */
class LocalService{
  static final LocalService _singleton = LocalService._internal();

  LocalService._internal();

  factory LocalService() {
    return _singleton;
  }

  Future<ConfigPrefs> getConfigPrefs(){
    return SharedPreferences.getInstance().then((prefs) {
      print(prefs.getInt("opcaoNotificacao") ?? 1);
      ConfigPrefs config = ConfigPrefs(); 
      config.usuarioMAL =  prefs.getString("usuarioMAL") ?? "";
      config.opcaoNotificacao =  prefs.getInt("opcaoNotificacao") ?? 1;
      return config;
    });
  }

  salvarPrefs(ConfigPrefs configPrefs){
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('usuarioMAL', configPrefs.usuarioMAL);
      prefs.setInt('opcaoNotificacao', configPrefs.opcaoNotificacao);
    });
  }

  //Marca um anime como assistindo, esse anime será notificado para o usuário no dia que sair o episódio da semana. id é o id do anime no MAL
  Future<void> adicionarMarcacaoAnime(int id) async {
    print("VIVA");

    await SharedPreferences.getInstance().then((prefs) {
      List<String> animes = [];
      if(prefs.containsKey("animeLista")){
        animes = prefs.getStringList("animeLista");
      }
      animes.add(id.toString());
      prefs.setStringList('animeLista', animes);
    });
    return;
  }
  
  Future<void> removerMarcacaoAnime(int id) async {
    await SharedPreferences.getInstance().then((prefs) {
      List<String> animes = prefs.getStringList("animeLista");
      animes.remove(id.toString());
      prefs.setStringList('animeLista', animes);
    });
    return;
  }

  //Retorna todos os animes que o usuário está acompanhando, que são exatamente todos que estão salvos.
  Future<List<int>> getAnimes() async {
    print("getAnimes");
    List<int> animeLista = [];
    await SharedPreferences.getInstance().then((prefs) {
      if(prefs.containsKey("animeLista")){
        List<String> animes = prefs.getStringList("animeLista");
        animeLista = animes.map(int.parse).toList();
      }
    });
    return animeLista;
  }
}