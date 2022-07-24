import 'package:animeschedule/core/ApiResponse.dart';
import 'package:animeschedule/domain/AnimeLocal.dart';

import '../domain/AnimeDetails.dart';


abstract class IAnimeAPiService{

  Future<void> loadJsonDataByWeekday(int weekday);

  Future<List<AnimeLocal>> fetchJsonDataScheduledAnimesOfWeek();

  Future<List<AnimeLocal>> fetchJsonDatafromFile();

  Future<List<AnimeLocal>> findAllByDay(selectedDay); 

  Future<List<AnimeLocal>> findAll(); 

  Future<AnimeDetails> loadAnimeDetails(int id);
}