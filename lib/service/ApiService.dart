import 'package:animeschedule/model/Anime.dart';
import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/util/Properties.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService{
  factory ApiService() {
    return _singleton;
  }
  static final ApiService _singleton = ApiService._internal();

  static final Map _diasSemana = {"monday": "Segunda", "tuesday": "Terça", "wednesday": "Quarta", "thursday": "Quinta", "friday": "Sexta", "saturday": "Sábado", "sunday": "Domingo", }; 
  static final List<String> _diasSemanaLista = [ "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]; 
  ApiService._internal();

  listarAnimesUsuario(usuarioMal) async{
    String url = Properties.URL_API_CONSULTA + "/user/"+usuarioMal+"/animelist/watching";    
    http.Response response = await http.get(url);
    ApiResponse apiResponse;
    if (response.statusCode == 200) {
      var dadosJson = json.decode(response.body);
      //print(dadosJson);
      List<Anime> lista = [];
      for (var item in dadosJson['anime']) {
        //print(item);
        Anime anime = Anime.fromJson(item);
        lista.add(anime);
      }
      
      apiResponse = ApiResponse<List<Anime>>(data: lista, isError: false);
      return apiResponse;
    }

  }

  Future<ApiResponse> listarAnimesPorDia(diaSelecionado) async{
    print("Dia selecionado: "+diaSelecionado.toString());
    String url = Properties.URL_API_CONSULTA + "/schedule";    
    print(url);
    http.Response response = await http.get(
      url,
    );
    print(response.statusCode);
    ApiResponse apiResponse;
    if (response.statusCode == 200) {
      var dadosJson = json.decode(response.body);
      List<Anime> lista = [];
      String dia = _diasSemanaLista[diaSelecionado];
      for (var item in dadosJson[dia]) {
        Anime anime = Anime.fromJson(item);
        anime.diaSemana = _diasSemana[dia];
        lista.add(anime);
      }
      
      apiResponse = ApiResponse<List<Anime>>(data: lista, isError: false);
    }
    print(apiResponse.isError);
    return apiResponse;
  }
}