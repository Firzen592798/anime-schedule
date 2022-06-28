import 'package:intl/intl.dart';

import 'AnimeDetails.dart';

class AnimeLocal implements Comparable<AnimeLocal> {
  int _id;
  String _titulo;
  int _episodios;
  String _urlImagem;
  bool _marcado;
  String _correctBroadcastDay;
  String _correctBroadcastTime;
  DateTime _correctBroadcastStart;
  DateTime _correctBroadcastEnd;
  AnimeDetails _animeDetails;

  AnimeDetails get animeDetails => this._animeDetails;

  set animeDetails(AnimeDetails animeDetails) => this._animeDetails = animeDetails;

  AnimeLocal();

  AnimeLocal.fromJson(Map<String, dynamic> json){
    _id = json['mal_id'] ?? 0;
    _titulo = json['title'] ?? "";
    _urlImagem = json['image_url'] ?? "";
    _episodios = json['episodes'] ?? 0;
    _correctBroadcastEnd =  json['correct_broadcast_end'] == null ? null : DateTime.parse(json['correct_broadcast_end']);
    _correctBroadcastDay = json['correct_broadcast_day'] ?? "";
    _correctBroadcastTime = json['correct_broadcast_time'] ?? "";
    _correctBroadcastStart = json['correct_broadcast_start'] ?? "";
    _marcado = false;
  }

  Map<String, dynamic> toJson() => {
    'mal_id': _id,
    'title': _titulo,
    'image_url': _urlImagem,
    'episodes': _episodios,
    'correct_broadcast_end':_correctBroadcastEnd != null ? _correctBroadcastEnd.toIso8601String() : null,
    'correct_broadcast_day': _correctBroadcastDay,
    'correct_broadcast_time': _correctBroadcastTime,
    'correct_broadcast_start': _correctBroadcastStart,
  };


  get id => this._id;

  set id(value) => this._id = value;

  get titulo => this._titulo;

  set titulo(value) => this._titulo = value;

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

  DateTime get correctBroadcastStart => this._correctBroadcastStart;

  set correctBroadcastStart(DateTime value) => this._correctBroadcastStart = value;

  DateTime get correctBroadcastEnd => this._correctBroadcastEnd;

  set correctBroadcastEnd(DateTime value) => this._correctBroadcastEnd = value;

  String get transmissionRange {
    String transmissionRangeStr = this.correctBroadcastStart != null ? DateFormat("dd/MM/yyyy").format(this.correctBroadcastStart) +" - " : "";
    transmissionRangeStr += this.correctBroadcastEnd == null ? "Indefinido" : DateFormat("dd/MM/yyyy").format(this.correctBroadcastEnd) ;
    return transmissionRangeStr;
  }

  @override
  int compareTo(AnimeLocal other) {
    return this.correctBroadcastTime.compareTo(other.correctBroadcastTime);
  }
}
