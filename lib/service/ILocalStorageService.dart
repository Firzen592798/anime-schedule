import '../model/Anime.dart';
import '../core/ConfigPrefs.dart';

abstract class ILocalStorageService{
  Future<ConfigPrefs> getConfigPrefs();

  salvarPrefs(ConfigPrefs configPrefs);

  Future<void>adicionarMarcacaoAnime(Anime anime);

  Future<void> removerMarcacaoAnime(int id);

  Future<List<Anime>> getMarkedAnimes();

  Future<List<Anime>> getMarkedAnimesByDay(int day);
}