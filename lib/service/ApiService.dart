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
  static final List<String> _diasSemanaLista = [ "monday", "sunday", "wednesday", "thursday", "friday", "saturday"]; 
  ApiService._internal();

  Future<ApiResponse> listarAnimes(diaSelecionado) async{
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
      print(dadosJson);
      for (var item in dadosJson[dia]) {
        print(item);
        Anime anime = Anime.fromJson(item);
        anime.diaSemana = _diasSemana[dia];
        lista.add(anime);
        //print(anime);
      }
      
      apiResponse = ApiResponse<List<Anime>>(data: lista, isError: false);
    }
    print(apiResponse.isError);
    return apiResponse;
  }
}