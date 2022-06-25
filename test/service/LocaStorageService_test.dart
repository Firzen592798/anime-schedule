import 'dart:convert';

import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:animeschedule/service-impl/LocalStorageService.dart';
import 'package:animeschedule/service/IAnimeApiService.dart';
import 'package:animeschedule/service/ILocalStorageService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockJikanApiService extends Mock implements JikanApiService{}

class MockLocalStorageService extends Mock implements ILocalStorageService{}

void main() {
  ILocalStorageService localStorageService = LocalStorageService();
  
  IAnimeAPiService animeApiServiceMock = JikanApiService();

  ILocalStorageService localStorageMock = MockLocalStorageService();
  
  Anime newAnime(int id, String title) {
    Anime anime = Anime();
    anime.id = id;
    anime.titulo = title;
    anime.correctBroadcastDay ="Mondays";
    anime.correctBroadcastTime = "08:00";
    anime.correctBroadcastEnd = DateTime(2022, 6, 6);
    return anime;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  setInitialMockValues({qtd = 1}) {
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
        "type": "type"
      };
      initialStringList.add(jsonEncode(initialAnimeMap).toString());
    }
    SharedPreferences.setMockInitialValues({"animeList": initialStringList});
  }

  group('adicionarMarcacaoAnime', () {
    test( 'Adicionar um novo anime em uma lista zerada, espera-se que tenha um registro na lista',  () async {
      await localStorageService.adicionarMarcacaoAnime(newAnime(1, "Naruto"));
      SharedPreferences.getInstance().then((prefs) {
        expect(prefs.containsKey("animeList"), true);
        List<String> animeList = prefs.getStringList("animeList");
        expect(animeList.length, 1);
        print(animeList.toString());
        Anime addedAnime = Anime.fromJsonLocal(jsonDecode(animeList[0]));
        expect(addedAnime.id, 1);
        expect(addedAnime.correctBroadcastDay, "Mondays");
        expect(addedAnime.correctBroadcastTime, "08:00");
        expect(addedAnime.correctBroadcastEnd.day, 6);
        expect(addedAnime.correctBroadcastEnd.month, 6);
        expect(addedAnime.correctBroadcastEnd.year, 2022);
      });
    });

    test(
        'Adicionar um novo anime em uma lista que já possui um registro inicial, espera-se que hajam 2 registros',
        () async {
      //SharedPreferences.setMockInitialValues(<String, Object>{'counter': 1});
      setInitialMockValues();
      await localStorageService.adicionarMarcacaoAnime(newAnime(2, "Bleach"));
      SharedPreferences.getInstance().then((prefs) {
        List<String> animeList = prefs.getStringList("animeList");
        expect(animeList.length, 2);
        Anime addedAnime = Anime.fromJsonLocal(jsonDecode(animeList[1]));
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
      List<Anime> lista = await localStorageService.getMarkedAnimes();
      expect(lista.length, 0);
    });

    test("Se a lista tiver com um elemento, espera-se um retorno condizente", () async {
      setInitialMockValues();
      List<Anime> lista = await localStorageService.getMarkedAnimes();
      expect(lista.length, 1);
    });

    test("Se a lista tiver com três elementos, espera-se um retorno condizente", () async {
      setInitialMockValues(qtd: 3);
      List<Anime> lista = await localStorageService.getMarkedAnimes();
      expect(lista.length, 3);
    });
  });

  group("getMarkedAnimesByDay", () {
    test("Se a lista tiver vazia, espera-se um retorno sem nada", () async {
      List<Anime> lista = await localStorageService.getMarkedAnimesByDay(0);
      expect(lista.length, 0);
    });

    test("Se a lista tiver com 2 itens no dia Monday e for passado o 0 como parâmetro, espera-se uma lista com 2 animes como resultado", () async {
      setInitialMockValues(qtd: 2);
      List<Anime> lista = await localStorageService.getMarkedAnimesByDay(0);
      expect(lista.length, 2);
    });

    test("Se a lista tiver com 2 itens no dia Monday e 3 Sunday e for passado o 6(domingo) como parâmetro, espera-se uma lista de 3 animes como resultado", () async {
      setInitialMockValues(qtd: 5);
      List<Anime> lista = await localStorageService.getMarkedAnimesByDay(6);
      expect(lista.length, 3);
    });
  });

}
