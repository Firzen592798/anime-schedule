import 'package:animeschedule/service/JikanApiService.dart';
import 'package:animeschedule/service/LocalStorageService.dart';
import 'package:animeschedule/service/SchedulerService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:animeschedule/model/Anime.dart';

class MockLocalStorageService extends Mock implements LocalStorageService{}

class MockJikanApiService extends Mock implements JikanApiService{}

void main() {
  SchedulerService schedulerService;
  MockLocalStorageService localService;
  MockJikanApiService jikanApiService;
  Anime newAnime(int id, String title, [int weekday = 0]) {
    Anime anime = Anime();
    anime.id = id;
    anime.titulo = title;
    anime.correctBroadcastDay = Anime.diasSemanaListaCapitalized[weekday];
    anime.correctBroadcastTime = "08:00";
    anime.correctBroadcastEnd = DateTime(2022, 6, 6 + weekday); //segunda
    return anime;
  }

  setUp(() {
      localService = MockLocalStorageService();
      jikanApiService = MockJikanApiService();
      schedulerService = SchedulerService();
      schedulerService.localService = localService;
      schedulerService.jikanApiService = jikanApiService;

  });

  group('doRemoveMarksOfFinishedAnimes', () {

    test('Remover marcação de animes encerrados dia 06 e 07 de junho de 2022, espera-se que dado que a data de hoje seja 8, os dois animes sejam removidos',  () async {
      List<Anime> animes = [];
      animes.add(newAnime(1, "T1")); 
      animes.add(newAnime(2, "T2", 1));
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 8));
      expect(result, 2);
    });

    test('Remover marcação de animes encerrados dia 06 e 07 de junho de 2022, espera-se que dado que a data de hoje seja 5, nada seja removido',  () async {
      List<Anime> animes = [];
      animes.add(newAnime(1, "T1")); 
      animes.add(newAnime(2, "T2", 1));
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 5));
      expect(result, 0);
    });

    test('Remover marcação de animes encerrados dia 06 de junho de 2022, espera-se que dado que a data de hoje seja 6, nada seja removido',  () async {
      List<Anime> animes = [];
      animes.add(newAnime(1, "T1")); 
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 6));
      expect(result, 0);
    });

    test('Remover marcação de animes encerrados dia 06 e 08 de junho de 2022, espera-se que dado que a data de hoje seja 7, apenas o anime q encerra dia 06 seja removido',  () async {
      List<Anime> animes = [];
      animes.add(newAnime(1, "T1")); 
      animes.add(newAnime(2, "T2", 2));
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 7));
      expect(result, 1);
    });
  });
}