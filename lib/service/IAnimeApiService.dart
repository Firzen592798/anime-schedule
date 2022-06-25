import 'package:animeschedule/core/ApiResponse.dart';
import 'package:animeschedule/model/Anime.dart';

import '../domain/AnimeDetails.dart';


abstract class IAnimeAPiService{

  Future<ApiResponse<List<Anime>>> listarAnimesUsuario(usuarioMal);

  Future<void> loadJsonDataByWeekday(int weekday);

  Future<List<Anime>> fetchJsonDataScheduledAnimesOfWeek();

  Future<List<Anime>> fetchJsonDatafromFile();

  Future<List<Anime>> findAllByDay(selectedDay); 

  Future<AnimeDetails> loadAnimeDetails(int id);
}