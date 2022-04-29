class Anime{
  int _id;
  String _titulo;
  String _tipo;
  String _estudio;
  String _diaSemana;
  int _episodios;
  int _episodiosAssistidos;
  double _score;
  DateTime _dataLancamento;
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

  DateTime get dataLancamento => _dataLancamento;

  set dataLancamento(DateTime value) => _dataLancamento = value;
  
  String get estudio => _estudio;

  set estudio(String value) => _estudio = value;

  String get diaSemana => _diaSemana;

  set diaSemana(String value) => _diaSemana = value;

  int get episodiosAssistidos => _episodiosAssistidos;

  set episodiosAssistidos(int value) => _episodiosAssistidos = value;
  
  bool get marcado => this._marcado;

  set marcado(bool _marcado) => this._marcado = _marcado;

  Anime.fromJson(Map<String, dynamic> json){
    _id = json['mal_id'];
    _titulo = json['title'];
    _urlImagem = json['image_url'];
    _episodios = json['episodes'];
    _episodiosAssistidos = json['watched_episodes'];
    _tipo = json['type'];
    _marcado = false;
  }

  Map<String, dynamic> toJson() => {
    'mal_id': _id,
    'title': _titulo,
    'image_url': _urlImagem,
    'episodes': _episodios,
    'watched_episodes': _episodiosAssistidos,
    'type': _tipo,
  };


  /*Anime.fromJson(var dadosJson){
    _id = dadosJson["id"];
    _idUsuarioAPI = dadosJson["idUsuarioAPI"];
    _urlFotoAPI = dadosJson["usuario"]["urlFotoAPI"];
  }*/
}