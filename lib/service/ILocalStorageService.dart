import '../domain/AnimeLocal.dart';
import '../domain/ConfigPrefs.dart';

abstract class ILocalStorageService{
  Future<ConfigPrefs> getConfigPrefs();

  salvarPrefs(ConfigPrefs configPrefs);

  Future<void>adicionarMarcacaoAnime(AnimeLocal anime);

  Future<void> removerMarcacaoAnime(int id);

  Future<void>atualizarMarcacoes(List<AnimeLocal> animeLista);

  Future<List<AnimeLocal>> getMarkedAnimes();

  Future<List<AnimeLocal>> getMarkedAnimesByDay(int day);

  void removerMarcacaoAnimesFinalizados([DateTime dateTime]);
}