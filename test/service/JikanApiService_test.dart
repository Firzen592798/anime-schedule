import 'package:animeschedule/domain/AnimeDetails.dart';
import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/service-impl/JikanApiService.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements Client{}

void main() {
  JikanApiService api = JikanApiService();

  MockHttpClient httpMock = MockHttpClient();


  group('timeDiffToJapan', () {
     test('Cenário normal', () {
       expect(api.getTimezoneDiffToJapan(), -12);
     });
  });

  group('getCorrectedBroadcastEnd', () {
      test('Espera-se que o dia corrigido pela timezone fique 24 no horário 23:59', () {
        DateTime dt = api.getCorrectedBroadcastEnd("2022-06-25T00:00:00+00:00", "11:59");
        expect(dt.day, 24);
     });

      test('Espera-se que o dia corrigido pela timezone continue 25 no horário 0:00', () {
          DateTime dt = api.getCorrectedBroadcastEnd("2022-06-25T00:00:00+00:00", "12:00");
          expect(dt.day, 25);
      });
  });
  
  group('getDiffOfDaysBetweenSelectedAndBroadcastDay', () {
    test('Ao passar a diferença de timezone como 10, se espera que a diferença de dias seja 0', () {
       expect(api.getDiffOfDaysBetweenSelectedAndBroadcastDay("11:59", 10), 0);
     });
     test('Ao passar a diferença de timezone como -2, se espera que a diferença de dias seja -1', () {
       expect(api.getDiffOfDaysBetweenSelectedAndBroadcastDay("0:00", -2), -1);
     });

    test('Ao passar a diferença de timezone como -2, se espera que a diferença de dias seja 1', () {
       expect(api.getDiffOfDaysBetweenSelectedAndBroadcastDay("22:00", 2), 1);
     });

    test('Cenário adverso em que a hora é passada como vazia', () {
       expect(api.getDiffOfDaysBetweenSelectedAndBroadcastDay("", 0), 0);
     });

    test('Cenário adverso em que a hora é passada como nula', () {
       expect(api.getDiffOfDaysBetweenSelectedAndBroadcastDay(null, 0), 0);
     });
  });

  group('getCorrectedBroadcastTime', () {
    test('Cenário normal', () {
      expect(api.getCorrectedBroadcastTime("22:00", -12), "10:00");
    });
    test('Cenário normal sem parâmetro opcional', () {
      expect( api.getCorrectedBroadcastTime("22:00"), "10:00");
    });
    test('Tempo final com zero no início', () {
      expect(api.getCorrectedBroadcastTime("13:00", -12), "01:00");
    });

    test('Adicionando 12 horas a 10:59', () {
      expect(api.getCorrectedBroadcastTime("10:59", 12), "22:59");
    });

    test('Adicionando 1 hora a 01:00', () {
      expect(api.getCorrectedBroadcastTime("01:00", 1), "02:00");
    });

    test('Adicionando 1 hora a 1:00', () {
      expect(api.getCorrectedBroadcastTime("1:00", 1), "02:00");
    });

    test('Adicionando 2 hora a 23:00. É esperado um retorno de 01:00 com daydiff de 1', () {
      expect(api.getCorrectedBroadcastTime("23:00", 2), "01:00");
    });

    test('Retirando 2 horas de 01:59. É esperado um retorno de 23:59 com daydiff de -1', () {
      expect(api.getCorrectedBroadcastTime("01:59", -2), "23:59");
    });

    test('Retirando 12 horas de 03:00. É esperado um retorno de 23:59 com daydiff de -1', () {
      expect(api.getCorrectedBroadcastTime("03:00", -12), "15:00");
    });
    
  });

  group('verifyIfIsAnimeInSelectedDay', () {
     test('Ao selecionar 0(segunda) e o anime tá dizendo que é segunda às 20:00, espera-se que o anime lance às 08:00 no Brasil na Segunda', () {
       expect(api.verifyIfIsAnimeInSelectedDay(0, "Mondays", "20:00"), true);
     });
      test('Ao selecionar 0(segunda) e o anime tá dizendo que é segunda às 12:00, espera-se que o anime lance às 00:00 no Brasil na Segunda', () {
       expect(api.verifyIfIsAnimeInSelectedDay(0, "Mondays", "12:00"), true);
     });

     test('Ao selecionar 6(domingo) e o anime tá dizendo que é segunda às 0:00, espera-se que o anime lance às 12:00 no Brasil no Domingo', () {
       expect(api.verifyIfIsAnimeInSelectedDay(6, "Mondays", "0:00"), true);
     });

    test('Ao selecionar 5(sábado) e o anime tá dizendo que é sábado às 3:30, espera-se que o anime lance às 15:30 no Brasil na Sexta', () {
       expect(api.verifyIfIsAnimeInSelectedDay(5, "Saturdays", "3:30"), false);
    });

    test('Ao selecionar 4(sexta) e o anime tá dizendo que é sábado às 3:30, espera-se que o anime lance às 15:30 no Brasil na Sexta', () {
       expect(api.verifyIfIsAnimeInSelectedDay(4, "Saturdays", "3:30"), true);
    });
  });

    group('loadAnimeDetails', () {
    const String animeDetalhesJson = '''
    {
      "data": {
        "mal_id": 1064,
        "url": "https://myanimelist.net/anime/1064/Mazinkaiser",
        "images": {
          "jpg": {
            "image_url": "https://cdn.myanimelist.net/images/anime/1041/106091.jpg",
            "small_image_url": "https://cdn.myanimelist.net/images/anime/1041/106091t.jpg",
            "large_image_url": "https://cdn.myanimelist.net/images/anime/1041/106091l.jpg"
          },
          "webp": {
            "image_url": "https://cdn.myanimelist.net/images/anime/1041/106091.webp",
            "small_image_url": "https://cdn.myanimelist.net/images/anime/1041/106091t.webp",
            "large_image_url": "https://cdn.myanimelist.net/images/anime/1041/106091l.webp"
          }
        },
        "trailer": {
          "youtube_id": "hs-uyrX-xlc",
          "url": "https://www.youtube.com/watch?v=hs-uyrX-xlc",
          "embed_url": "https://www.youtube.com/embed/hs-uyrX-xlc?enablejsapi=1&wmode=opaque&autoplay=1",
          "images": {
            "image_url": "https://img.youtube.com/vi/hs-uyrX-xlc/default.jpg",
            "small_image_url": "https://img.youtube.com/vi/hs-uyrX-xlc/sddefault.jpg",
            "medium_image_url": "https://img.youtube.com/vi/hs-uyrX-xlc/mqdefault.jpg",
            "large_image_url": "https://img.youtube.com/vi/hs-uyrX-xlc/hqdefault.jpg",
            "maximum_image_url": "https://img.youtube.com/vi/hs-uyrX-xlc/maxresdefault.jpg"
          }
        },
        "title": "Mazinkaiser",
        "title_english": "Mazinkaiser",
        "title_synonyms": [],
        "type": "OVA",
        "source": "Manga",
        "episodes": 7,
        "status": "Finished Airing",
        "airing": false,
        "aired": {
          "from": "2001-09-25T00:00:00+00:00",
          "to": "2002-09-20T00:00:00+00:00",
          "prop": {
            "from": {
              "day": 25,
              "month": 9,
              "year": 2001
            },
            "to": {
              "day": 20,
              "month": 9,
              "year": 2002
            }
          },
          "string": "Sep 25, 2001 to Sep 20, 2002"
        },
        "duration": "30 min per ep",
        "rating": "R+ - Mild Nudity",
        "score": 7.32,
        "scored_by": 3997,
        "rank": 2376,
        "popularity": 5685,
        "members": 9561,
        "favorites": 56,
        "synopsis": "Dr. Hell and his Mechanical Beasts are back, and they're more dangerous than ever before. Kouji Kabuto and Tetsuya Tsurugi fight a fierce battle against these hellish machines, which are under the command of Baron Ashura. Unfortunately, they are defeated, with Kouji's Mazinger Z being captured and Tetsuya's Great Mazinger seriously damaged by the enemy. The devious Dr. Hell quickly converts the captured robot into Ashura Mazinger and uses it to attack the Photo Power Lab. At the same time, Kouji is missing in action, which leaves Testuya to defend the lab in the damaged Great Mazinger. But the forces of Dr. Hell are too strong, even for a brave pilot such as Tetsuya, and all seems to be lost. The battle seems to be drawing to a close, until an overpowering blast fired by an unknown robot destroys the entire Mechanical Beast army. Could this mysterious robot be the legendary Mazinkaiser, and who is piloting it?",
        "background": null,
        "season": null,
        "year": null,
        "broadcast": {
          "day": null,
          "time": null,
          "timezone": null,
          "string": null
        },
        "producers": [
          {
            "mal_id": 23,
            "type": "anime",
            "name": "Bandai Visual",
            "url": "https://myanimelist.net/anime/producer/23/Bandai_Visual"
          },
          {
            "mal_id": 322,
            "type": "anime",
            "name": "Bee Media",
            "url": "https://myanimelist.net/anime/producer/322/Bee_Media"
          },
          {
            "mal_id": 921,
            "type": "anime",
            "name": "Dynamic Planning",
            "url": "https://myanimelist.net/anime/producer/921/Dynamic_Planning"
          }
        ],
        "licensors": [
          {
            "mal_id": 97,
            "type": "anime",
            "name": "ADV Films",
            "url": "https://myanimelist.net/anime/producer/97/ADV_Films"
          }
        ],
        "studios": [
          {
            "mal_id": 112,
            "type": "anime",
            "name": "Brain's Base",
            "url": "https://myanimelist.net/anime/producer/112/Brains_Base"
          }
        ],
        "genres": [
          {
            "mal_id": 2,
            "type": "anime",
            "name": "Adventure",
            "url": "https://myanimelist.net/anime/genre/2/Adventure"
          },
          {
            "mal_id": 4,
            "type": "anime",
            "name": "Comedy",
            "url": "https://myanimelist.net/anime/genre/4/Comedy"
          },
          {
            "mal_id": 24,
            "type": "anime",
            "name": "Sci-Fi",
            "url": "https://myanimelist.net/anime/genre/24/Sci-Fi"
          }
        ],
        "explicit_genres": [],
        "themes": [
          {
            "mal_id": 18,
            "type": "anime",
            "name": "Mecha",
            "url": "https://myanimelist.net/anime/genre/18/Mecha"
          }
        ],
        "demographics": [
          {
            "mal_id": 27,
            "type": "anime",
            "name": "Shounen",
            "url": "https://myanimelist.net/anime/genre/27/Shounen"
          }
        ],
        "relations": [
          {
            "relation": "Adaptation",
            "entry": [
              {
                "mal_id": 8772,
                "type": "manga",
                "name": "Mazinkaiser",
                "url": "https://myanimelist.net/manga/8772/Mazinkaiser"
              }
            ]
          },
          {
            "relation": "Sequel",
            "entry": [
              {
                "mal_id": 2734,
                "type": "anime",
                "name": "Mazinkaiser: Shitou! Ankoku Dai Shogun",
                "url": "https://myanimelist.net/anime/2734/Mazinkaiser__Shitou_Ankoku_Dai_Shogun"
              }
            ]
          },
          {
            "relation": "Alternative version",
            "entry": [
              {
                "mal_id": 5658,
                "type": "anime",
                "name": "Great Mazinger",
                "url": "https://myanimelist.net/anime/5658/Great_Mazinger"
              }
            ]
          },
          {
            "relation": "Spin-off",
            "entry": [
              {
                "mal_id": 8666,
                "type": "anime",
                "name": "Mazinkaiser SKL",
                "url": "https://myanimelist.net/anime/8666/Mazinkaiser_SKL"
              }
            ]
          }
        ],
        "theme": {
          "openings": [
            "Fire Wars by Jam Project"
          ],
          "endings": [
            "Tornado by JAM Project featuring Ichiro Mizuki"
          ]
        },
        "external": [
          {
            "name": "Official Site",
            "url": "http://www.bandaivisual.co.jp/mazinger/series/index.html"
          },
          {
            "name": "AnimeDB",
            "url": "http://anidb.info/perl-bin/animedb.pl?show=anime&aid=953"
          },
          {
            "name": "AnimeNewsNetwork",
            "url": "http://www.animenewsnetwork.com/encyclopedia/anime.php?id=1007"
          },
          {
            "name": "Wikipedia",
            "url": "http://en.wikipedia.org/wiki/Mazinkaiser"
          }
        ]
      }
    }
    ''';
    
    
    test('Verifica se o método vai carregar corretamente os dados', () async {
      when(httpMock.get(any)).thenAnswer((_) async => Response(animeDetalhesJson, 200));
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
}