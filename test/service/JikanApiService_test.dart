import 'package:animeschedule/domain/AnimeDetails.dart';
import 'package:animeschedule/domain/AnimeLocal.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

import '../json.dart';

class MockHttpClient extends Mock implements Client{}

void main() {
  JikanApiService api = JikanApiService();

  MockHttpClient httpMock = MockHttpClient();

  group('loadAnimeDetails', () {
    test('Verifica se o método vai carregar corretamente os dados', () async {
      when(httpMock.get(any)).thenAnswer((_) async => Response(Json.ANIME_DETALHES, 200));
      api.httpClient = httpMock;
      AnimeDetails animeDetails = await api.loadAnimeDetails(1064);
      expect(animeDetails.urlImagemGrande, isNotEmpty);
      expect(animeDetails.genres.length, 3);
      expect(animeDetails.studios.length, 1);
      expect(animeDetails.studios[0], "Brain's Base");
      expect(animeDetails.openings[0], "Fire Wars by Jam Project");
      expect(animeDetails.endings[0], "Tornado by JAM Project featuring Ichiro Mizuki");
    });
  });

  group('findAllByDay', () {

    ///Ninjala -  "Saturdays at 10:30 (JST)" -> Expect Friday 22:30
    ///Boruto - "Sundays at 17:30 (JST)" -> Expect Sunday 5:30
    ///Spy x Family - "Saturdays at 23:00 (JST)" -> Expect Saturday 11:00
    ///Kaguya Sama - "Saturdays at 00:00 (JST)" -> Expect Friday 12:00
    api.httpClient = httpMock;
    test('Ao passar como parâmetro segunda(0), espera-se que nada seja retornado', () async {
      var answers = [
        Response(Json.ANIME_LISTA_SATURDAY, 200),
        Response(Json.ANIME_LISTA_SUNDAY, 200)
      ];
      when(httpMock.get(any)).thenAnswer((_) async => answers.removeAt(0));
      List<AnimeLocal> lista =  await api.findAllByDay(0);
      expect(lista.length, 0);
    });

    test('Ao passar como parâmetro sábado(5), espera-se 1 registros retornados', () async {
      var answers = [
        Response(Json.ANIME_LISTA_SATURDAY, 200),
        Response(Json.ANIME_LISTA_SUNDAY, 200)
      ];
      when(httpMock.get(any)).thenAnswer((_) async => answers.removeAt(0));
      List<AnimeLocal> lista =  await api.findAllByDay(5);
      expect(lista.length, 1);
      expect(lista[0].id, 50265);
      expect(lista[0].titulo, "Spy x Family");
      expect(lista[0].correctBroadcastDay, "Saturdays");
      expect(lista[0].correctBroadcastTime, "11:00");
      expect(lista[0].marcado, false);
      expect(DateFormat("dd/MM/yyyy").format(lista[0].correctBroadcastStart), "09/04/2022");
      expect(lista[0].correctBroadcastEnd, null);
    });

    test('Ao passar como parâmetro domingo(6), espera-se 1 registros retornado', () async {
      var answers = [
        Response(Json.ANIME_LISTA_SUNDAY, 200),
        Response(Json.ANIME_LISTA_VAZIA, 200)
      ];
      when(httpMock.get(any)).thenAnswer((_) async => answers.removeAt(0));
      List<AnimeLocal> lista =  await api.findAllByDay(6);
      expect(lista.length, 1);
      expect(lista[0].correctBroadcastDay, "Sundays");
      expect(lista[0].correctBroadcastTime, "05:30");
    });

    test('Ao passar como parâmetro friday(4), espera-se 2 registros retornados', () async {
      var answers = [
        Response(Json.ANIME_LISTA_VAZIA, 200),
        Response(Json.ANIME_LISTA_SATURDAY, 200)
      ];
      when(httpMock.get(any)).thenAnswer((_) async => answers.removeAt(0));
      List<AnimeLocal> lista =  await api.findAllByDay(4);
      expect(lista.length, 2);
      expect(DateFormat("dd/MM/yyyy").format(lista[0].correctBroadcastEnd), "24/06/2022");
      expect(lista[0].correctBroadcastDay, "Fridays");
      expect(lista[0].correctBroadcastTime, "12:00");
      expect(lista[1].correctBroadcastDay, "Fridays");
      expect(lista[1].correctBroadcastTime, "22:30");
    });

    test('Ao passar como parâmetro saturday(5), espera-se 1 registros retornados', () async {
      var answers = [
        Response(Json.ANIME_LISTA_SATURDAY, 200),
        Response(Json.ANIME_LISTA_SUNDAY, 200)
      ];
      when(httpMock.get(any)).thenAnswer((_) async => answers.removeAt(0));
      List<AnimeLocal> lista =  await api.findAllByDay(5);
      expect(lista.length, 1);
      expect(lista[0].correctBroadcastDay, "Saturdays");
      expect(lista[0].correctBroadcastTime, "11:00");
    });
  });
}