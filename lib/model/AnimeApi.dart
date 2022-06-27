import 'package:animeschedule/domain/AnimeDetails.dart';

class AnimeApi{
  int _id;
  String _titulo;
  String _tipo;
  String _estudio;
  String _broadcastTimeApi;
  String _broadcastDayApi;
  String _broadcastStartApi;
  String _broadcastEndApi;
  int _episodios;
  int _episodiosAssistidos;
  double _score;
  String _urlImagem;
  bool _marcado;
  
  AnimeDetails _animeDetails;

  AnimeDetails get animeDetails => this._animeDetails;

  set animeDetails(AnimeDetails animeDetails) => this._animeDetails = animeDetails;

  String get titulo => _titulo;

  set titulo(String value) => _titulo = value;

  int get id => _id;

  set id(int value) => _id = value;

  String get tipo => _tipo;

  set tipo(String value) => _tipo = value;

  int get episodios => _episodios;

  set episodios(int value) => _episodios = value;

  double get score => _score;

  set score(double value) => _score = value;

  String get urlImagem => _urlImagem;

  set urlImagem(String value) => _urlImagem = value;

  String get estudio => _estudio;

  set estudio(String value) => _estudio = value;

  String get broadcastDayApi => this._broadcastDayApi;

  set broadcastDayApi( value) => this._broadcastDayApi = value;

  String get broadcastTimeApi => this._broadcastTimeApi;

  set broadcastTimeApi( value) => this._broadcastTimeApi = value;

  int get episodiosAssistidos => _episodiosAssistidos;

  set episodiosAssistidos(int value) => _episodiosAssistidos = value;
  
  bool get marcado => this._marcado;

  set marcado(bool _marcado) => this._marcado = _marcado;

  String get broadcastStartApi => this._broadcastStartApi;

  set broadcastStartApi( value) => this._broadcastStartApi = value;
 
  String get broadcastEndApi => this._broadcastEndApi;

  set broadcastEndApi( value) => this._broadcastEndApi = value;

  Anime(){}

  convertJson(Map<String, dynamic> json){

  }
  
  AnimeApi.fromJson(Map<String, dynamic> json){
    _id = json['mal_id'] ?? 0;
    _titulo = json['title'] ?? "";
    _urlImagem = json['images']['jpg']['image_url'] ?? "";
    _broadcastTimeApi =  json['broadcast']['time'] ?? "--:--";
    _broadcastDayApi =  json['broadcast']['day'] ?? "";
    _broadcastEndApi =  json['aired']['to'] ?? "";
    _broadcastStartApi =  json['aired']['from'] ?? "";
    _episodios = json['episodes'] ?? 0;
    _episodiosAssistidos = json['watched_episodes']  ?? 0;
    _tipo = json['type'] ?? "";
    _marcado = false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is AnimeApi
        && other.id == id;
  }
}