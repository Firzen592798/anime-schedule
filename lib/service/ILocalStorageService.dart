import '../domain/AnimeLocal.dart';
import '../domain/ConfigPrefs.dart';
import '../domain/User.dart';

abstract class ILocalStorageService{
  Future<ConfigPrefs> getConfigPrefs();

  salvarPrefs(ConfigPrefs configPrefs);

  Future<void>adicionarMarcacaoAnime(AnimeLocal anime);

  Future<void> removerMarcacaoAnime(int id);

  Future<void>atualizarMarcacoes(List<AnimeLocal> animeLista);

  Future<List<AnimeLocal>> getMarkedAnimes();

  Future<List<AnimeLocal>> getMarkedAnimesByDay(int day);

  void removerMarcacaoAnimesFinalizados([DateTime dateTime]);

  Future<String> saveToken(String token);

  Future<String> getToken();

  Future<String> saveUser(User user);

  Future<User> getUser();

  Future<void> deslogar();

  void printStorage();
}