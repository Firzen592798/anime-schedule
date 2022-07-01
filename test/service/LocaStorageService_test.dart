import 'dart:convert';

import 'package:animeschedule/domain/AnimeLocal.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:animeschedule/service-impl/LocalStorageService.dart';
import 'package:animeschedule/service/ILocalStorageService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockJikanApiService extends Mock implements JikanApiService{}

class MockLocalStorageService extends Mock implements ILocalStorageService{}

void main() {
  ILocalStorageService localStorageService = LocalStorageService();
  
  AnimeLocal newAnime(int id, String title) {
    AnimeLocal anime = AnimeLocal();
    anime.id = id;
    anime.titulo = title;
    anime.correctBroadcastDay ="Mondays";
    anime.correctBroadcastTime = "08:00";
    anime.correctBroadcastEnd = DateTime(2022, 6, 6);
    anime.correctBroadcastStart = DateTime(2022, 3, 3);
    return anime;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  List<String> setInitialMockValues({qtd = 1, DateTime broadcastEnd}) {
    if(broadcastEnd == null){
      broadcastEnd = DateTime(2022, 6, 6);
    }
    List<String> initialStringList = [];
    for (int i = 1; i <= qtd; i++) {
      Map<String, Object> initialAnimeMap = {
        "mal_id": i,
        "title": "Naruto $i",
        "image_url": null,
        "episodes": 1,
        "watched_episodes": 1,
        "correct_broadcast_day": i <= 2 ? "Mondays" : "Sundays",
        "correct_broadcast_time": "08:00",
        "correct_broadcast_end": broadcastEnd.toIso8601String(),
        "type": "type"
      };
      initialStringList.add(jsonEncode(initialAnimeMap).toString());
    }
    SharedPreferences.setMockInitialValues({"animeList": initialStringList});
    return initialStringList;
  }

  group('adicionarMarcacaoAnime', () {
    test( 'Adicionar um novo anime em uma lista zerada, espera-se que tenha um registro na lista',  () async {
      await localStorageService.adicionarMarcacaoAnime(newAnime(1, "Naruto"));
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.containsKey("animeList"), true);
        List<String> animeList = prefs.getStringList("animeList");
        expect(animeList.length, 1);
        print(animeList.toString());
        AnimeLocal addedAnime = AnimeLocal.fromJson(jsonDecode(animeList[0]));
        expect(addedAnime.id, 1);
        expect(addedAnime.correctBroadcastDay, "Mondays");
        expect(addedAnime.correctBroadcastTime, "08:00");
        expect(addedAnime.correctBroadcastEnd.day, 6);
        expect(addedAnime.correctBroadcastEnd.month, 6);
        expect(addedAnime.correctBroadcastEnd.year, 2022);
      });
    });

    test('Adicionar um novo anime em uma lista que já possui um registro inicial, espera-se que hajam 2 registros', 
      () async {
      //SharedPreferences.setMockInitialValues(<String, Object>{'counter': 1});
      setInitialMockValues();
      await localStorageService.adicionarMarcacaoAnime(newAnime(2, "Bleach"));
      SharedPreferences.getInstance().then((prefs) {
        List<String> animeList = prefs.getStringList("animeList");
        expect(animeList.length, 2);
        AnimeLocal addedAnime = AnimeLocal.fromJson(jsonDecode(animeList[1]));
        expect(addedAnime.id, 2);
      });
    });
  });

  group("removerMarcacaoAnime", () {
    test(
        'Remover um registro da lista, espera-se que não haja registros inseridos no final da operação',
        () async {
      setInitialMockValues();
      await localStorageService.removerMarcacaoAnime(1);
      SharedPreferences.getInstance().then((prefs) {
        List<String> animeList = prefs.getStringList("animeList");
        expect(animeList.length, 0);
      });
    });

    test(
        'Remover um registro da lista, espera-se que restem 2 elementos dos 3 iniciais',
        () async {
      setInitialMockValues(qtd: 3);
      await localStorageService.removerMarcacaoAnime(2);
      SharedPreferences.getInstance().then((prefs) {
        List<String> animeList = prefs.getStringList("animeList");
        expect(animeList.length, 2);
      });
    });

    test(
        'Remover um registro da lista já vazia, espera-se que não haja registros inseridos no final da operação',
        () async {
      //SharedPreferences.setMockInitialValues(<String, Object>{'counter': 1});
      await localStorageService.removerMarcacaoAnime(1);
      SharedPreferences.getInstance().then((prefs) {
        List<String> animeList = prefs.getStringList("animeList");
        expect(animeList.length, 0);
      });
    });
  });

  group("getMarkedAnimes", () {
    test("Se a lista tiver vazia, espera-se um retorno sem nada", () async {
      List<AnimeLocal> lista = await localStorageService.getMarkedAnimes();
      expect(lista.length, 0);
    });

    test("Se a lista tiver com um elemento, espera-se um retorno condizente", () async {
      setInitialMockValues();
      List<AnimeLocal> lista = await localStorageService.getMarkedAnimes();
      expect(lista.length, 1);
    });

    test("Se a lista tiver com três elementos, espera-se um retorno condizente", () async {
      setInitialMockValues(qtd: 3);
      List<AnimeLocal> lista = await localStorageService.getMarkedAnimes();
      expect(lista.length, 3);
    });
  });

  group("removerMarcacaoAnimesFinalizados", () {
    test("Dado a data atual superior a dos animes salvos em local, espera-se a remoção dos animes", () async {
       setInitialMockValues(qtd:2);
       await localStorageService.removerMarcacaoAnimesFinalizados(DateTime(2022, 6, 7));
       SharedPreferences.getInstance().then((prefs) {
       List<String> animeList = prefs.getStringList("animeList");
       expect(0, animeList.length);
      });
    });

    test("Dado a data atual igual a dos animes salvos em local, nenhuma remoção deve acontecer", () async {
       setInitialMockValues(qtd:2);
       await localStorageService.removerMarcacaoAnimesFinalizados(DateTime(2022, 6, 5));
       SharedPreferences.getInstance().then((prefs) {
       List<String> animeList = prefs.getStringList("animeList");
       expect(2, animeList.length);
      });
    });

    test("Dado a data atual menor a dos animes salvos em local, nenhuma remoção deve acontecer", () async {
       setInitialMockValues(qtd:2);
       await localStorageService.removerMarcacaoAnimesFinalizados(DateTime(2022, 6, 5));
       SharedPreferences.getInstance().then((prefs) {
       List<String> animeList = prefs.getStringList("animeList");
       expect(2, animeList.length);
      });
    });

    test("Dado que o broadcastEnd dos animes salvos é null, nenhuma remoção deve acontecer", () async {
       setInitialMockValues(qtd:2);
       await localStorageService.removerMarcacaoAnimesFinalizados(DateTime(2022, 6, 5));
       SharedPreferences.getInstance().then((prefs) {
       List<String> animeList = prefs.getStringList("animeList");
       expect(2, animeList.length);
      });
    });
  });

  group("getMarkedAnimesByDay", () {
    test("Se a lista tiver vazia, espera-se um retorno sem nada", () async {
      List<AnimeLocal> lista = await localStorageService.getMarkedAnimesByDay(0);
      expect(lista.length, 0);
    });

    test("Se a lista tiver com 2 itens no dia Monday e for passado o 0 como parâmetro, espera-se uma lista com 2 animes como resultado", () async {
      setInitialMockValues(qtd: 2);
      List<AnimeLocal> lista = await localStorageService.getMarkedAnimesByDay(0);
      expect(lista.length, 2);
    });

    test("Se a lista tiver com 2 itens no dia Monday e 3 Sunday e for passado o 6(domingo) como parâmetro, espera-se uma lista de 3 animes como resultado", () async {
      setInitialMockValues(qtd: 5);
      List<AnimeLocal> lista = await localStorageService.getMarkedAnimesByDay(6);
      expect(lista.length, 3);
    });
  });

  group("atualizarMarcacoes", () {
    test("", () async {
      setInitialMockValues(qtd: 1);
      List<AnimeLocal> animes = [newAnime(1, "N1")];
      await localStorageService.atualizarMarcacoes(animes);
      SharedPreferences.getInstance().then((prefs) {
        List<String> animeList = prefs.getStringList("animeList");
        AnimeLocal savedAnime = AnimeLocal.fromJson(jsonDecode(animeList[0]));
        expect("N1", savedAnime.titulo);
        expect("06/06/2022", DateFormat("dd/MM/yyyy").format(savedAnime.correctBroadcastEnd));
        expect("03/03/2022", DateFormat("dd/MM/yyyy").format(savedAnime.correctBroadcastStart));
      });
    });
  });
}
