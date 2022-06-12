class AnimeDetails {
  DateTime _correctBroadcastStart;
  String _synopsis;
  String _urlImagemGrande;
  List<String> _studios;
  List<String> _genres;
  get correctBroadcastStart => this._correctBroadcastStart;

  set correctBroadcastStart(value) => this._correctBroadcastStart = value;

  get synopsis => this._synopsis;

  set synopsis(value) => this._synopsis = value;

  get urlImagemGrande => this._urlImagemGrande;

  set urlImagemGrande(value) => this._urlImagemGrande = value;

  List<String> get studios => this._studios;

  set studios(List<String> value) => this._studios = value;

  List<String> get genres => this._genres;

  set genres(List<String> value) => this._genres = value;
}
