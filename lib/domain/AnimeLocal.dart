class AnimeLocal implements Comparable<AnimeLocal> {
  int _id;
  String _titulo;
  String _tipo;
  String _estudio;
  int _episodios;
  String _correctBroadcastDay;
  String _correctBroadcastTime;
  String _urlImagem;
  bool _marcado;
  DateTime _correctBroadcastStart;
  DateTime _correctBroadcastEnd;

  get id => this._id;

  set id(value) => this._id = value;

  get titulo => this._titulo;

  set titulo(value) => this._titulo = value;

  get tipo => this._tipo;

  set tipo(value) => this._tipo = value;

  get estudio => this._estudio;

  set estudio(value) => this._estudio = value;

  get episodios => this._episodios;

  set episodios(value) => this._episodios = value;

  get correctBroadcastDay => this._correctBroadcastDay;

  set correctBroadcastDay(value) => this._correctBroadcastDay = value;

  get correctBroadcastTime => this._correctBroadcastTime;

  set correctBroadcastTime(value) => this._correctBroadcastTime = value;

  get urlImagem => this._urlImagem;

  set urlImagem(value) => this._urlImagem = value;

  get marcado => this._marcado;

  set marcado(value) => this._marcado = value;

  get correctBroadcastStart => this._correctBroadcastStart;

  set correctBroadcastStart(value) => this._correctBroadcastStart = value;

  get correctBroadcastEnd => this._correctBroadcastEnd;

  set correctBroadcastEnd(value) => this._correctBroadcastEnd = value;
  @override
  int compareTo(AnimeLocal other) {
    return this.correctBroadcastTime.compareTo(other.correctBroadcastTime);
  }
}
