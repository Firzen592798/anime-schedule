class Anime{
  
  static final List<String> diasSemanaListaCapitalized = [ "Mondays", "Tuesdays", "Wednesdays", "Thursdays", "Fridays", "Saturdays", "Sundays"]; 
  
  int _id;
  String _titulo;
  String _tipo;
  String _estudio;
  String _correctBroadcastDay;
  String _broadcastDayApi;
  int _episodios;
  int _episodiosAssistidos;
  double _score;
  String _broadcastTimeApi;
  String _correctBroadcastTime;
  String _urlImagem;
  bool _marcado;

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

  get broadcastDayApi => this._broadcastDayApi;

  set broadcastDayApi( value) => this._broadcastDayApi = value;

  get broadcastTimeApi => this._broadcastTimeApi;

  set broadcastTimeApi( value) => this._broadcastTimeApi = value;

  int get episodiosAssistidos => _episodiosAssistidos;

  set episodiosAssistidos(int value) => _episodiosAssistidos = value;
  
  bool get marcado => this._marcado;

  set marcado(bool _marcado) => this._marcado = _marcado;

  get correctBroadcastDay => this._correctBroadcastDay;

  set correctBroadcastDay( value) => this._correctBroadcastDay = value;

  get correctBroadcastTime => this._correctBroadcastTime;

  set correctBroadcastTime( value) => this._correctBroadcastTime = value;
 
  Anime(){}

  Anime.fromJson(Map<String, dynamic> json){
    _id = json['mal_id'] ?? 0;
    _titulo = json['title'] ?? "";
    _urlImagem = json['images']['jpg']['image_url'] ?? "";
    _broadcastTimeApi =  json['broadcast']['time'] ?? "--:--";
    _broadcastDayApi =  json['broadcast']['day'] ?? "";
    _episodios = json['episodes'] ?? 0;
    _episodiosAssistidos = json['watched_episodes']  ?? 0;
    _tipo = json['type'] ?? "";
    _marcado = false;
  }

  Anime.fromJsonLocal(Map<String, dynamic> json){
    _id = json['mal_id'] ?? 0;
    _titulo = json['title'] ?? "";
    _urlImagem = json['image_url'] ?? "";
    _episodios = json['episodes'] ?? 0;
    _episodiosAssistidos = json['watched_episodes']  ?? 0;
    _correctBroadcastDay = json['correct_broadcast_day'] ?? "";
    _correctBroadcastTime = json['correct_broadcast_time'] ?? "";
    _tipo = json['type'] ?? "";
    _marcado = false;
  }

  Map<String, dynamic> toJson() => {
    'mal_id': _id,
    'title': _titulo,
    'image_url': _urlImagem,
    'episodes': _episodios,
    'watched_episodes': _episodiosAssistidos,
    'correct_broadcast_day': _correctBroadcastDay,
    'correct_broadcast_time': _correctBroadcastTime,
    'type': _tipo,
  };

  /*Anime.fromJson(var dadosJson){
    _id = dadosJson["id"];
    _idUsuarioAPI = dadosJson["idUsuarioAPI"];
    _urlFotoAPI = dadosJson["usuario"]["urlFotoAPI"];
  }*/
}