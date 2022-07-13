import 'dart:convert';
import 'dart:math';

import 'package:animeschedule/core/Properties.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../domain/AnimeLocal.dart';

class MALService {
  String codeChallenge = "";

  factory MALService() {
    return _singleton;
  }

  Client _httpClient = Client();

  set httpClient(Client mock) => this._httpClient = mock;

  static final MALService _singleton = MALService._internal();

  MALService._internal();

  String getRandString(int len) {
    final Random random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values).replaceAll("=", "").replaceAll("+", "-").replaceAll("/", "_");

    
  }

  String gerarCodeChallenge() {
    return getRandString(50);
  }

  String getAuthorizationPage() {
    this.codeChallenge = gerarCodeChallenge();
    String authorizationUrl = Properties.URL_API_AUTENTICACAO +
        "?response_type=code&client_id=" +
        Properties.CLIENT_ID +
        "&code_challenge=" +
        codeChallenge +
        "&state=" +
        Properties.STATE;
    //print(authorizationUrl);
    //print("Code challenge: "+codeChallenge);
    return authorizationUrl;
  }

  Future<String> generateToken(String authCode) async {
    print("Auth code: "+authCode);
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    };
    Map<String, String> params = {
        'client_id': Properties.CLIENT_ID,
        'client_secret': Properties.CLIENT_SECRET,
        'code': authCode,
        'code_verifier': codeChallenge,
        'grant_type': 'authorization_code',
    };
    final response = await http.post(

      Uri.parse(Properties.URL_API_TOKEN),
      headers: headers,
      body: params,
      encoding: Encoding.getByName("utf-8")
    );

    return response.body;
  }

  redirect(Uri authorizationUrl) async {
    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl);
    }
  }

  Future<List<AnimeLocal>> getUserWatchingAnimeList(String token) async{
    List<AnimeLocal> animeData = [];
    String url = Properties.URL_API_MAL + "/users/@me/animelist?status=watching&limit=150";
    print(url);
    String loadedData = await loadFromURL(url, token);
    var dadosJson = jsonDecode(loadedData);
    for (var item in dadosJson["data"]) {
      AnimeLocal anime = AnimeLocal();
      anime.id = item["node"]["id"];
      anime.titulo = item["node"]["title"];
      anime.urlImagem = item["node"]["main_picture"]["medium"];
      animeData.add(anime);
    }
    return animeData;
  }

  Future<String> loadFromURL(String url, String token) async{
    Response response;
    print(token);
    response = await _httpClient.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${token}",
      }
    );
    if(response.statusCode == 200){
      print(response.body);
      return response.body;
    }else{
      print(response.statusCode);
      print(response.headers);
      throw Exception(response.body);
    }
  }
}
