import 'package:animeschedule/mapper/AnimeMapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Client;
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements Client{}

void main() {

  group('timeDiffToJapan', () {
     test('Cenário normal', () {
       expect(AnimeMapper.getTimezoneDiffToJapan(), -12);
     });
  });

  group('getCorrectedBroadcastDate', () {
      test('Espera-se que o dia corrigido pela timezone fique 24 no horário 23:59', () {
        DateTime dt = AnimeMapper.getCorrectedBroadcastDate("2022-06-25T00:00:00+00:00", "11:59");
        expect(dt.day, 24);
     });

      test('Espera-se que o dia corrigido pela timezone continue 25 no horário 0:00', () {
          DateTime dt = AnimeMapper.getCorrectedBroadcastDate("2022-06-25T00:00:00+00:00", "12:00");
          expect(dt.day, 25);
      });
  });
  
  group('getDiffOfDaysBetweenSelectedAndBroadcastDay', () {
    test('Ao passar a diferença de timezone como 10, se espera que a diferença de dias seja 0', () {
       expect(AnimeMapper.getDiffOfDaysBetweenSelectedAndBroadcastDay("11:59", 10), 0);
     });
     test('Ao passar a diferença de timezone como -2, se espera que a diferença de dias seja -1', () {
       expect(AnimeMapper.getDiffOfDaysBetweenSelectedAndBroadcastDay("0:00", -2), -1);
     });

    test('Ao passar a diferença de timezone como -2, se espera que a diferença de dias seja 1', () {
       expect(AnimeMapper.getDiffOfDaysBetweenSelectedAndBroadcastDay("22:00", 2), 1);
     });

    test('Cenário adverso em que a hora é passada como vazia', () {
       expect(AnimeMapper.getDiffOfDaysBetweenSelectedAndBroadcastDay("", 0), 0);
     });

    test('Cenário adverso em que a hora é passada como nula', () {
       expect(AnimeMapper.getDiffOfDaysBetweenSelectedAndBroadcastDay(null, 0), 0);
     });
  });

  group('getCorrectedBroadcastTime', () {
    test('Cenário normal', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("22:00", -12), "10:00");
    });
    test('Cenário normal sem parâmetro opcional', () {
      expect( AnimeMapper.getCorrectedBroadcastTime("22:00"), "10:00");
    });
    test('Tempo final com zero no início', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("13:00", -12), "01:00");
    });

    test('Adicionando 12 horas a 10:59', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("10:59", 12), "22:59");
    });

    test('Adicionando 1 hora a 01:00', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("01:00", 1), "02:00");
    });

    test('Adicionando 1 hora a 1:00', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("1:00", 1), "02:00");
    });

    test('Adicionando 2 hora a 23:00. É esperado um retorno de 01:00 com daydiff de 1', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("23:00", 2), "01:00");
    });

    test('Retirando 2 horas de 01:59. É esperado um retorno de 23:59 com daydiff de -1', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("01:59", -2), "23:59");
    });

    test('Retirando 12 horas de 03:00. É esperado um retorno de 23:59 com daydiff de -1', () {
      expect(AnimeMapper.getCorrectedBroadcastTime("03:00", -12), "15:00");
    });
    
  });

  group('verifyIfIsAnimeInSelectedDay', () {
     test('Ao selecionar 0(segunda) e o anime tá dizendo que é segunda às 20:00, espera-se que o anime lance às 08:00 no Brasil na Segunda', () {
       expect(AnimeMapper.verifyIfIsAnimeInSelectedDay(0, "Mondays", "20:00"), true);
     });
      test('Ao selecionar 0(segunda) e o anime tá dizendo que é segunda às 12:00, espera-se que o anime lance às 00:00 no Brasil na Segunda', () {
       expect(AnimeMapper.verifyIfIsAnimeInSelectedDay(0, "Mondays", "12:00"), true);
     });

     test('Ao selecionar 6(domingo) e o anime tá dizendo que é segunda às 0:00, espera-se que o anime lance às 12:00 no Brasil no Domingo', () {
       expect(AnimeMapper.verifyIfIsAnimeInSelectedDay(6, "Mondays", "0:00"), true);
     });

    test('Ao selecionar 5(sábado) e o anime tá dizendo que é sábado às 3:30, espera-se que o anime lance às 15:30 no Brasil na Sexta', () {
       expect(AnimeMapper.verifyIfIsAnimeInSelectedDay(5, "Saturdays", "3:30"), false);
    });

    test('Ao selecionar 4(sexta) e o anime tá dizendo que é sábado às 3:30, espera-se que o anime lance às 15:30 no Brasil na Sexta', () {
       expect(AnimeMapper.verifyIfIsAnimeInSelectedDay(4, "Saturdays", "3:30"), true);
    });
  });

}