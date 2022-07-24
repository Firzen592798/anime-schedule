import 'package:animeschedule/core/ApiResponse.dart';
import 'package:animeschedule/domain/AnimeLocal.dart';
import 'package:animeschedule/domain/User.dart';
import 'package:animeschedule/service-impl/MALService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' show Client, Response;

import '../json.dart';

class MockHttpClient extends Mock implements Client{}

void main() {
  MALService malService = MALService();

  MockHttpClient httpMock = MockHttpClient();

  group("getUserWatchingAnimeList", (){
    test("Ao chamar o método, espera-se que a lista correspondente seja retornada", () async {
       when(httpMock.get(any, headers: {"Authorization": "Bearer ",})).thenAnswer((_) async => Response(Json.LIST_BY_USER, 200));
      malService.httpClient = httpMock;
      List<AnimeLocal> animes = await malService.getUserWatchingAnimeList("");
      expect(12, animes.length);
      expect(40507, animes[0].id);
      expect("Arifureta Shokugyou de Sekai Saikyou 2nd Season", animes[0].titulo);
      expect("https://api-cdn.myanimelist.net/images/anime/1877/119668.jpg", animes[0].urlImagem);
      expect(51096, animes[11].id);
      expect("Youkoso Jitsuryoku Shijou Shugi no Kyoushitsu e (TV) 2nd Season", animes[11].titulo);
      expect("https://api-cdn.myanimelist.net/images/anime/1010/124180.jpg", animes[11].urlImagem);
    });
  });

  group("getUserData", (){
    test("Ao chamar o método, espera-se que o usuário correspondente seja retornado", () async {
      when(httpMock.get(any, headers: {"Authorization": "Bearer ",})).thenAnswer((_) async => Response(Json.USER_DATA, 200));
      malService.httpClient = httpMock;
      ApiResponse<User> response  = await malService.getUserData("");
      User user = response.data;
      expect(1179953, user.id);
      expect("https://api-cdn.myanimelist.net/images/userimages/1179953.jpg?t=1658088000", user.picture);
      expect("Firzen592798", user.name);
    });
  });
}