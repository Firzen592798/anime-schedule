import 'package:animeschedule/service/ApiService.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  ApiService api = ApiService();
  group('timeDiffToJapan', () {
     test('Cenário normal', () {
       expect(api.getTimezoneDiffToJapan(), -12);

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
}