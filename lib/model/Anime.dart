class Anime{
  int _id;
  String _titulo;
  String _tipo;
  String _estudio;
  String _diaSemana;
  int _episodios;
  double _score;
  DateTime _dataLancamento;
  String _urlImagem;

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
  
  Anime.fromJson(Map<String, dynamic> json){
    _id = json['mal_id'];
    _titulo = json['title'];
    _urlImagem = json['image_url'];
    //_dataLancamento = json['airing_start'];
    _episodios = json['episodes'];
    _score = json['score'];
    //_estudio = json['producers'][0]['name'];
    _tipo = json['type'];

  }

  /*Anime.fromJson(var dadosJson){
    _id = dadosJson["id"];
    _idUsuarioAPI = dadosJson["idUsuarioAPI"];
    _urlFotoAPI = dadosJson["usuario"]["urlFotoAPI"];
  }*/
}