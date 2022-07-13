import 'package:animeschedule/domain/AnimeLocal.dart';
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
      malService.httpClient = httpMock;
      when(httpMock.get(any)).thenAnswer((_) async => Response(Json.LIST_BY_USER, 200));
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
}