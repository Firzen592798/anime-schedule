import 'dart:convert';
import 'dart:math';

import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/util/Properties.dart';
import 'package:http/http.dart' as http;

class MALService{

    String codeChallenge = "";

    factory MALService() {
        return _singleton;
    }
    static final MALService _singleton = MALService._internal();

    MALService._internal();

    String getRandString(int len) {
        final Random random = Random.secure();
        var values = List<int>.generate(len, (i) =>  random.nextInt(255));
        return base64UrlEncode(values);
    }

    String gerarCodeChallenge(){
        return getRandString(128);
    }

    String gerarPaginaAutenticacao(usuarioMal){
      codeChallenge = gerarCodeChallenge();
      String url = Properties.URL_API_AUTENTICACAO + "?response_type=code&client_id="+Properties.CLIENT_ID+"?code_challenge="+codeChallenge+"&state="+Properties.STATE;
      return url;
  }
}