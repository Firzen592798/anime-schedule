import 'package:animeschedule/util/ApiResponse.dart';
import 'package:animeschedule/util/Properties.dart';
import 'package:http/http.dart' as http;

class ApiService{
  factory ApiService() {
    return _singleton;
  }
  static final ApiService _singleton = ApiService._internal();

  ApiService._internal();

  Future<ApiResponse<List<String>>> listarAnimes(String token) async{
    String url = Properties.URL_API_CONSULTA + "/anime";    
    http.Response response = await http.get(
      url,
      headers: {"Authorization": "Bearer " + token},
    );

  }
}