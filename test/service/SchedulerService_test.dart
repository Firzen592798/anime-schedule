import 'dart:convert';

import 'package:animeschedule/core/Consts.dart';
import 'package:animeschedule/domain/AnimeLocal.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:animeschedule/service-impl/LocalStorageService.dart';
import 'package:animeschedule/service-impl/SchedulerService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

class MockLocalStorageService extends Mock implements LocalStorageService{}

class MockJikanApiService extends Mock implements JikanApiService{}

void main() {
  SchedulerService schedulerService;
  MockLocalStorageService localService;
  MockJikanApiService jikanApiService;
  AnimeLocal newAnime(int id, String title,  {int weekday = 0, String correctBroadcastTime =  "08:00", DateTime correctBroadcastStart, DateTime correctBroadcastEnd}) {
    AnimeLocal anime = AnimeLocal();
    anime.id = id;
    anime.titulo = title;
    anime.correctBroadcastDay = Consts.diasSemanaListaCapitalized[weekday];
    anime.correctBroadcastTime = correctBroadcastTime;
    anime.correctBroadcastStart = correctBroadcastStart ?? DateTime(2022, 3, 3);
    if(correctBroadcastEnd == null){
      anime.correctBroadcastEnd = DateTime(2022, 6, 6 + weekday); //segunda
    }else{
       anime.correctBroadcastEnd = correctBroadcastEnd;   
    }
    return anime;
  }

  setUp(() {
      localService = MockLocalStorageService();
      jikanApiService = MockJikanApiService();
      schedulerService = SchedulerService();
      schedulerService.localService = localService;
      schedulerService.jikanApiService = jikanApiService;

  });

  group('doUpdateEndBroadcastOfLocalData', () {
    test('caso base', () async{
      List<AnimeLocal> animesRemote = [];
      animesRemote.add(newAnime(1, "T1", weekday: 0, correctBroadcastTime: "10:00")); 
      animesRemote.add(newAnime(2, "T2", weekday: 5, correctBroadcastTime: "07:00"));
      
      List<AnimeLocal> animesLocal = [];
      animesLocal.add(newAnime(1, "T1", weekday: 0, correctBroadcastTime: "10:00", correctBroadcastStart: DateTime(2022, 6, 11))); 
      animesLocal.add(newAnime(2, "T2", weekday: 5, correctBroadcastStart: null, correctBroadcastTime: "00:00"));
      animesLocal[0].correctBroadcastEnd = null;
      animesLocal[1].correctBroadcastDay = "Sundays";
      
      when(jikanApiService.fetchJsonDatafromFile()).thenAnswer((_) async => animesRemote);
      when(localService.getMarkedAnimes()).thenAnswer((_) async => animesLocal);
      List<AnimeLocal> result = await schedulerService.doUpdateEndBroadcastOfLocalData();
      
      expect(result[0].correctBroadcastEnd.day, 6);
      expect(result[0].correctBroadcastStart.day, 3);
      expect(result[0].correctBroadcastTime, "10:00");
      expect(result[0].correctBroadcastDay, "Mondays");

      expect(result[1].correctBroadcastEnd.day, 11);
      expect(result[1].correctBroadcastStart.day, 3);
      expect(result[1].correctBroadcastTime, "07:00");
      expect(result[1].correctBroadcastDay, "Saturdays");
    }); 
  });

  group('doRemoveMarksOfFinishedAnimes', () {

    test('Remover marcação de animes encerrados dia 06 e 07 de junho de 2022, espera-se que dado que a data de hoje seja 8, os dois animes sejam removidos',  () async {
      List<AnimeLocal> animes = [];
      animes.add(newAnime(1, "T1")); 
      animes.add(newAnime(2, "T2", weekday: 1));
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 8));
      expect(result, 2);
    });

    test('Remover marcação de animes encerrados dia 06 e 07 de junho de 2022, espera-se que dado que a data de hoje seja 5, nada seja removido',  () async {
      List<AnimeLocal> animes = [];
      animes.add(newAnime(1, "T1")); 
      animes.add(newAnime(2, "T2", weekday: 1));
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 5));
      expect(result, 0);
    });

    test('Remover marcação de animes encerrados dia 06 de junho de 2022, espera-se que dado que a data de hoje seja 6, nada seja removido',  () async {
      List<AnimeLocal> animes = [];
      animes.add(newAnime(1, "T1")); 
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 6));
      expect(result, 0);
    });

    test('Remover marcação de animes encerrados dia 06 e 08 de junho de 2022, espera-se que dado que a data de hoje seja 7, apenas o anime q encerra dia 06 seja removido',  () async {
      List<AnimeLocal> animes = [];
      animes.add(newAnime(1, "T1")); 
      animes.add(newAnime(2, "T2", weekday: 2));
      when(jikanApiService.findAllByDay(any)).thenAnswer((_) async =>  animes);
      when(localService.getMarkedAnimesByDay(any)).thenAnswer((_) async =>  animes);
      int result = await schedulerService.doRemoveMarksOfFinishedAnimes(DateTime(2022, 6, 7));
      expect(result, 1);
    });
  });
}