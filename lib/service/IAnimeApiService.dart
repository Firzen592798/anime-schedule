import 'package:animeschedule/core/ApiResponse.dart';
import 'package:animeschedule/domain/AnimeLocal.dart';
import 'package:animeschedule/model/AnimeApi.dart';

import '../domain/AnimeDetails.dart';


abstract class IAnimeAPiService{

  Future<ApiResponse<List<AnimeApi>>> listarAnimesUsuario(usuarioMal);

  Future<void> loadJsonDataByWeekday(int weekday);

  Future<List<AnimeLocal>> fetchJsonDataScheduledAnimesOfWeek();

  Future<List<AnimeLocal>> fetchJsonDatafromFile();

  Future<List<AnimeLocal>> findAllByDay(selectedDay); 

  Future<AnimeDetails> loadAnimeDetails(int id);
}