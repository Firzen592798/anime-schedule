class AnimeDetails {
  String _synopsis;
  String _urlImagemGrande;
  List<String> _studios;
  List<String> _genres;
  List<String> _openings;
  List<String> _endings;
  
  get synopsis => this._synopsis;

  set synopsis(value) => this._synopsis = value;

  get urlImagemGrande => this._urlImagemGrande;

  set urlImagemGrande(value) => this._urlImagemGrande = value;

  List<String> get studios => this._studios;

  set studios(List<String> value) => this._studios = value;

  List<String> get genres => this._genres;

  set genres(List<String> value) => this._genres = value;

  List<String> get openings => this._openings;

  set openings(List<String> value) => this._openings = value;

  List<String> get endings => this._endings;

  set endings(List<String> value) => this._endings = value;

  AnimeDetails.fromJson(Map<String, dynamic> json){
      json = json['data'];
      _synopsis = json['synopsis'];
      _urlImagemGrande = json['images']['jpg']['large_image_url'];
      _genres = (json['genres'] as List).map((e) => e['name'] as String).toList();
      _studios = (json['studios'] as List).map((e) => e['name'] as String).toList();
      _openings = (json['theme']['openings'] as List).map((e) => e as String).toList();
      _endings = (json['theme']['endings'] as List).map((e) => e as String).toList();
  }
}
